# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

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
    closure  = pdefClosure' pdefs keylike;
    rootPdef = lib.libfloco.getPdef { inherit pdefs; } keylike;
  in __treeInfoFromClosure closure rootPdef;

  __treeInfoFromPdefs = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: __treeInfoFromPdefs' pdefs keylike;


# ---------------------------------------------------------------------------- #

in {

  inherit
    pdefClosure
    __mkTBNode
    __mkSubtree
    __topScope
    __mkTree
    __treeInfoFromClosure
    __treeInfoFromPdefs
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
