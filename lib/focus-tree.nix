# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  focusTree = {
    treeInfo ? null
  , tree     ? builtins.mapAttrs ( _: v: v.key ) treeInfo
  , pdefs
  # New root path, e.g. `foo' NOT a package "key".
  , newRoot
  }: let

# ---------------------------------------------------------------------------- #

    lookup  = lib.getPdef { inherit pdefs; };
    rootKey = tree.${newRoot};

# ---------------------------------------------------------------------------- #

    depsOf' = {
      ident   ? null
    , version ? null
    , key     ? if args ? pkey then tree.${args.pkey} else "${ident}/${version}"
    , ...
    } @ args: let
      di = ( lookup { inherit key; } ).depInfo;
    in lib.filterAttrs ( _: de: de.runtime ) di;


# ---------------------------------------------------------------------------- #

    parentNMs = pkey: let
      sp       = builtins.split "node_modules" pkey;
      dirPaths = builtins.filter builtins.isString sp;
      proc = { cwd, dirs }: p: {
        cwd  = "${cwd}${p}";
        dirs = dirs ++ ["${cwd}node_modules"];
      };
      da = builtins.foldl' proc { cwd = ""; dirs = []; } dirPaths;
    in da.dirs;

    reqsOf = {
      pkey
    , key  ? tree.${pkey}
    }: let
      deps = depsOf' { inherit key; };
      filt = i: ! ( treeInfo ? "${pkey}/node_modules/${i}" );
    in builtins.filter filt ( builtins.attrNames deps );

    resolve = from: ident: let
      pnms = parentNMs from;
      proc = resolved: nmdir:
        if tree ? "${nmdir}/${ident}" then "${nmdir}/${ident}" else resolved;
      fromParent = builtins.foldl' proc null pnms;
    in if tree ? "${from}/node_modules/${ident}"
       then "${from}/node_modules/${ident}"
       else fromParent;


# ---------------------------------------------------------------------------- #

    resolved = let
      close = builtins.genericClosure {
        startSet = [{ key = newRoot; }];
        operator = { key }: let
          paths = builtins.attrNames ( depsOf' { pkey = key; } );
        in map ( i: { key = resolve key i; } ) paths;
      };
      proc = acc: { key }: acc // { ${key} = tree.${key}; };
    in builtins.foldl' proc {} close;


# ---------------------------------------------------------------------------- #

    focused = let
      proc  = { tree, drop } @ acc: p: let
        lkey = lib.yank "${newRoot}/(.*)" p;
      in if ! ( lib.hasPrefix "${newRoot}/" p ) then acc else acc // {
        tree = tree // { ${lkey} = resolved.${p}; };
        drop =
          if ( resolved ? ${lkey} ) then drop // { ${lkey} = resolved.${p}; }
                                    else drop;
      };
      closed    = removeAttrs resolved [newRoot];
      clobbered = builtins.foldl' proc { tree = closed; drop = {}; }
                                       ( builtins.attrNames closed );
      top = lib.filterAttrs ( k: v: lib.hasPrefix "node_modules/" k )
                            clobbered.tree;
      rough = top // { "" = rootKey; };
      pulls = lib.filterAttrs ( k: v: lib.hasPrefix "node_modules/" k ) closed;
      fixClobbers = let
        proc = acc: p: let
          pdir = let
            d1 = dirOf p;
            d2 = dirOf d1;
            d  = if ( baseNameOf d1 ) != "node_modules" then d2 else d1;
          in if d == "node_modules" then "${p}/node_modules" else d;
          reqs  = reqsOf { pkey = p; };
          clobs =
            builtins.filter ( i: clobbered.drop ? ${( resolve p i )} ) reqs;
          fixSubtree = n: i: let
            p2s = lib.filterAttrs ( k: v: lib.hasPrefix "node_modules/${i}" k )
                                  closed;
            pnames = builtins.attrNames p2s;
            rename = s: { "${dirOf pdir}/${s}" = pulls.${s}; };
          in n // ( builtins.foldl' ( a: rename ) {} pnames );
        in acc // ( builtins.foldl' fixSubtree {} clobs );
      in ( builtins.foldl' proc rough ( builtins.attrNames pulls ) );
    in fixClobbers;


# ---------------------------------------------------------------------------- #

    markOptionals = let
      noOpt = let
        proc = acc: key: let
          pd = lookup { inherit key; };
        in lib.recursiveUpdate acc {
          #inherit (pd) ident version key;
          ${dirOf key}.${baseNameOf key}.depInfo = lib.filterAttrs ( _: d:
            d.runtime && ( ! d.optional )
          ) pd.depInfo;
        };
      in builtins.foldl' proc {} ( builtins.attrValues focused );
      markReqs = p: let
        ft = focusTree { tree = focused; pdefs = noOpt; newRoot = p; };
      in ft.resolved;
      markedSubs = let
        subs = noOpt.${dirOf rootKey}.${baseNameOf rootKey}.depInfo;
        proc = acc: p: acc // ( markReqs "node_modules/${p}" );
      in builtins.foldl' proc {} ( builtins.attrNames subs );
    in builtins.mapAttrs ( p: key: {
      inherit key;
      dev      = false;
      optional = ! ( ( p == "" ) || ( markedSubs ? ${p} ) );
    } ) focused;


# ---------------------------------------------------------------------------- #

  in { inherit resolved focused; treeInfo = markOptionals; };

  # End `focusTree' function.


# ---------------------------------------------------------------------------- #

in {
  inherit focusTree;
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
