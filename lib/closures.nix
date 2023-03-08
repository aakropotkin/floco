# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  getDepsWith = pred: x:
    lib.filterAttrs ( ident: entry:
      pred ( { inherit ident; } // entry )
    ) ( x.depInfo or x );

  getRuntimeDeps = {
    includeOptional ? true
  , includeBundled  ? false
  }: let
    pred = de:
      de.runtime &&
      ( includeOptional || ( ! de.optional ) ) &&
      ( includeBundled || ( ! de.bundled ) );
  in getDepsWith pred;

  getDevDeps = {
    includeOptional ? true
  , includeBundled  ? false
  }: let
    pred = de:
      de.dev &&
      ( includeOptional || ( ! de.devOptional ) ) &&
      ( includeBundled || ( ! de.bundled ) );
  in getDepsWith pred;


# ---------------------------------------------------------------------------- #

  pdefClosure' = pdefs: keylike: let
    mkNode = builtins.intersectAttrs {
      key     = true; ident    = true; version  = true;
      depInfo = true; peerInfo = true;
    };
    get = ident: { pin, ... }: let
      full = lib.libfloco.getPdef { inherit pdefs; } {
        inherit ident; version = pin;
      };
    in mkNode full;
    operator = pdef: builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
  in builtins.genericClosure {
    startSet = operator ( mkNode ( lib.libfloco.getPdef pdefs keylike ) );
    inherit operator;
  };

  pdefClosure = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosure' pdefs keylike;


# ---------------------------------------------------------------------------- #

  pdefClosureWith' = rootPred: pred: pdefs: keylike: let
    rootPdef = lib.libfloco.getPdef pdefs keylike;
    filterDeps = pdef: pdef // {
      depInfo = if rootPdef.key == pdef.key then getDepsWith rootPred pdef else
                getDepsWith pred pdef;
    };
    filtered = map filterDeps ( ( pdefClosure' pdefs keylike ) ++ [rootPdef] );
    pdefs'   = lib.libfloco.pdefsFromList filtered;
  in pdefClosure' pdefs' keylike;

  pdefClosureWith = rootPred: pred: {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosureWith' rootPred pred pdefs keylike;


# ---------------------------------------------------------------------------- #

  # Tree Builder Node.
  __mkTBNode = {
    ident    ? dirOf key
  , version  ? baseNameOf key
  , key      ? ident + "/" + version
  , depInfo  ? {}
  , peerInfo ? {}

  , path     ? "node_modules/" + ident
  , isRoot   ? ! ( lib.hasInfix "node_modules/" path )
  , pscope   ? if isRoot then {} else { ${ident} = version; }
  , requires ?
    lib.filterAttrs ( di: de: ( pscope.${di} or null ) == de.pin )
                    depInfo
  , children ? removeAttrs depInfo ( builtins.attrNames requires )
  , ...
  } @ args: let
    children' = builtins.mapAttrs ( di: de: de.pin or de ) children;
  in {
    inherit ident version key depInfo peerInfo path isRoot pscope;
    requires = builtins.mapAttrs ( di: de: de.pin or de ) requires;
    children = children';
    scope    = pscope // children';
  };


# ---------------------------------------------------------------------------- #

  __mkSubtree = closure: node: let
    getPdef = { ident, version, ... }: builtins.head ( builtins.filter ( p:
      ( p.ident == ident ) && ( p.version == version )
    ) closure );
    pprefix = if node.path == "" then "" else node.path + "/";
    proc = ident: pin: let
      cnode = __mkTBNode ( ( getPdef { inherit ident; version = pin; } ) // {
        path   = pprefix + "node_modules/" + ident;
        isRoot = false;
        pscope = node.scope;
      } );
      value = __mkSubtree closure cnode;
    in { name = value.path; inherit value; };
    subtrees = builtins.mapAttrs proc node.children;
  in node // {
    subtree = builtins.listToAttrs ( builtins.attrValues subtrees );
  };


# ---------------------------------------------------------------------------- #

  __topScope = closure: rootKey: let
    noRoot   = builtins.filter ( pdef: pdef.key != rootKey ) closure;
    idGroups = builtins.groupBy ( pdef: pdef.ident ) noRoot;
  in builtins.mapAttrs ( _: pdefs: ( builtins.head pdefs ).version ) idGroups;


# ---------------------------------------------------------------------------- #

  __mkTree = closure: rootPdef: let
    top      = __topScope closure rootPdef.key;
    rootNode = ( __mkTBNode ( rootPdef // {
      path     = "";
      isRoot   = true;
      requires = {};
      children = top;
    } ) ) // { scope = top; };
    subtrees = builtins.genericClosure {
      startSet = [( __mkSubtree closure rootNode )];
      operator = node: lib.collect ( v: v ? subtree ) node.subtree;
    };
  in builtins.foldl' ( acc: node: acc // node.subtree ) {} subtrees;


# ---------------------------------------------------------------------------- #

  # XXX: Incomplete draft
  # Produce a "hoisted" `treeInfo' record from a closure.
  # TODO: Mark `dev' and `optional' fields.
  # TODO: Audit `peerDepInfo'.
  # TODO: Don't include transitive `devDependencies'.
  # TODO: Hoist subtrees when possible to deduplicate. ( `yarn' strategy )
  __treeInfoFromClosure = closure: rootPdef: let
    tree = __mkTree closure rootPdef;
  in builtins.mapAttrs ( _: node: {
    inherit (node) key;
  } ) tree;


# ---------------------------------------------------------------------------- #

  __treeInfoFromPdefs' = pdefs: keylike: let
    closure  = pdefClosureWith' ( _: true ) ( de: de.runtime ) pdefs keylike;
    rootPdef = lib.libfloco.getPdef { inherit pdefs; } keylike;
  in __treeInfoFromClosure closure rootPdef;

  __treeInfoFromPdefs = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: __treeInfoFromPdefs' pdefs keylike;


# ---------------------------------------------------------------------------- #

  # Check that `peerDependencies' declared by direct dependencies are listed as
  # direct dependencies.
  # Do not audit versions/semver ranges, just check to see if they are present.`
  # Requires pins for all dependencies.
  checkPeersPresent' = pdefs: {
    key     ? ident + "/" + version
  , ident   ? dirOf key
  , version ? baseNameOf key
  }: let
    pdef  = lib.libfloco.getPdef pdefs { inherit ident version; };
    rtDIs = getRuntimeDeps { includeBundled = true; } pdef;
    deps = let
      get = ident: { pin, runtime ? false, optional ? false, ... }:
        ( lib.libfloco.getPdef pdefs { inherit ident; version = pin; } ) // {
          inherit runtime optional;
        };
    in builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
    checkOne = dp: {
      name  = dp.ident;
      value = let
        haves = if dp.runtime then rtDIs else pdef.depInfo;
        bads  = removeAttrs dp.peerInfo ( builtins.attrNames haves );
        part  = builtins.partition ( i: pdef.depInfo ? ${i} )
                                   ( builtins.attrNames bads );
      in {
        inherit (dp) runtime optional;
        missing = if dp.runtime then removeAttrs bads part.right else bads;
        moves   = if dp.runtime then removeAttrs bads part.wrong else {};
      };
    };
    checkAll = let
      pred = v: ( v.value.missing != {} ) || ( v.value.moves != {} );
    in builtins.filter pred ( map checkOne deps );
  in builtins.listToAttrs checkAll;

  checkPeersPresent = lib.libfloco.runNVFunction {
    modify = false;
    fn     = checkPeersPresent';
  };


# ---------------------------------------------------------------------------- #

  describeCheckPeersPresentEnt = ident: {
    runtime  ? false
  , optional ? false
  , missing  ? {}
  , moves    ? {}
  , ...
  }: let
    need     = o: if optional || o then "may be required" else "is required";
    when     = if runtime then "runtime" else "dev";
    descMove = di: { descriptor ? "*", optional ? false, ... }:
      "  + `${di}' is marked `dev', but ${need optional} in `runtime'";
    descMiss = di: { descriptor ? "*", optional ? false, ... }:
      "  + `${di}@${descriptor}' ${need optional} in `${when}'";
    moveMsgs = if ! runtime then [] else
               builtins.attrValues ( builtins.mapAttrs descMove moves );
    missMsgs = builtins.attrValues ( builtins.mapAttrs descMiss missing );
    msgs     = builtins.concatStringsSep "\n" ( missMsgs ++ moveMsgs );
    opt      = if optional then "" else " optional";
    okMsg    = "- `${ident}' (${when}${opt}) is okay";
    badMsg   = "- `${ident}' (${when}${opt}) may have `peer' issues:\n${msgs}";
  in if ( missing == {} ) && ( moves == {} ) then okMsg else badMsg;

  describeCheckPeersPresent = checked:
    builtins.concatStringsSep "\n\n" ( builtins.attrValues (
      builtins.mapAttrs lib.libfloco.describeCheckPeersPresentEnt checked
    ) );


# ---------------------------------------------------------------------------- #

in {

  inherit
    getDepsWith
    getRuntimeDeps
    getDevDeps
    pdefClosure
    pdefClosureWith
    __mkTBNode
    __mkSubtree
    __topScope
    __mkTree
    __treeInfoFromClosure
    __treeInfoFromPdefs
    checkPeersPresent
    describeCheckPeersPresentEnt
    describeCheckPeersPresent
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
