# ============================================================================ #
#
# This is a naive implementation of an impure translator that does not use IFD.
# Note that in the beta repository `github:aameen-tulip/at-node-nix' these same
# processes can be done purely, and support a wider range of options concerning
# fetchers; but for the time being I am focusing on migrating the simplest
# translation flow.
#
# NOTE: This translator is designed for `package-lock.json' of
# `lockfileVersion' 2 or 3.
# The beta repository implements a version 1 translator; but that is not being
# migrated at this time.
# While I do plan to eventually migrate this - I strongly suggest that users
# upgrade their projects to use the newer lockfile schema, since it carries
# significant performance improvements for NPM usage ( `floco' routines perform
# roughly the same using either lockfile, this isn't a bottleneck for us ).
#
# ---------------------------------------------------------------------------- #

{ lib
, lockDir
, plock   ? lib.importJSON ( lockDir + "/package-lock.json" )
, ...
}: let

# ---------------------------------------------------------------------------- #

  inherit (( lib.evalModules { modules = [../fetchers]; } ).config) fetchers;


# ---------------------------------------------------------------------------- #

  plconf = lib.evalModules {
    modules     = [../plock];
    specialArgs = { inherit lockDir plock; };
  };


# ---------------------------------------------------------------------------- #

  # Reference [[file:../plock/types.nix][plock types]] for fields.
  toPdef = plentKey: {
    ident
  , version
  , key
  , dependencies
  , devDependencies
  , devDependenciesMeta
  , peerDependencies
  , peerDependenciesMeta
  , optionalDependencies
  , requires
  , os
  , cpu
  , engines
  , bin
  , resolved
  # NOTE: We intentionally ignore hash fields, instead we operate under the
  # assumption that translation will be run in impure mode, allowing optimized
  # SHA256 hashes to be locked instead.
  # In the beta repository `github:aameen-tulip/at-node-nix' there is an
  # implementation which uses the `builtins:fetchurl' to purely convert SHA1 or
  # SHA512 to SHA256, but that has not been migrated at this time.
  #, integrity
  #, sha1
  , link
  , hasInstallScript
  , gypfile
  , ...
  } @ plent: let
    pp    = lib.generators.toPretty {} plent;
    ltype = if plentKey == "" then "dir" else
            if link then "link" else
            if lib.hasPrefix "file" resolved then "link" else
            if lib.hasPrefix "." plentKey then "dir" else
            if lib.hasPrefix "git+" resolved then "git" else
            if lib.hasPrefix "https" resolved then "file" else
            throw "Unable to derive lifecycle type from entry: '${pp}'.";
    # TODO: `github'
    fetchInfo = let
      type = if ltype == "file" then "tarball" else "git";
    in if builtins.elem ltype ["dir" "link"] then {
      path = let
        len = builtins.stringLength resolved;
      in if resolved == "." then lockDir else
         if lib.hasPrefix "file:" resolved
         then lockDir + ( "/" + ( builtins.substring 5 len resolved ) )
         else lockDir + ( "/" + resolved );
    } else if type == "git" then {
      inherit type;
      url        = resolved;
      allRefs    = false;
      submodules = false;
      shallow    = true;
      rev        = let
        m = builtins.match "[^#]+#([[:xdigit:]]{40})" resolved;
      in builtins.head m;
    } else {
      inherit type;
      url = resolved;
    };
  in {
    inherit ident version key ltype fetchInfo;

    binInfo.binPairs = bin;

    metaFiles = {
      inherit lockDir plentKey;
      plent = plock.packages.${plentKey};
    } // ( if plentKey != "" then {} else { inherit plock; } );

    fsInfo = { inherit gypfile; dir = "."; };

    lifecycle.install = hasInstallScript;

    _module.args.basedir = lockDir;
    _module.args.fetcher =
      if fetchInfo ? path then fetchers.path else
      fetchers."fetchTree_${fetchInfo.type}";

  };


# ---------------------------------------------------------------------------- #

  # `treeInfo' for root package
  rootTreeInfo = let
    mkTreeEnt = plentKey: plent: { inherit (plent) key optional dev; };
    noDotDot  = lib.filterAttrs ( path: _:
      ( path == "" ) || ( lib.hasPrefix "node_modules" path )
    ) plconf.config.plents;
  in builtins.mapAttrs mkTreeEnt noDotDot;

  rough = let
    proc = plentKey: plentRaw: [
      { config = toPdef plentKey plentRaw; }
    ] ++ (
      if plentKey == "" then [{
        config.treeInfo = removeAttrs rootTreeInfo [""];
        config._export.treeInfo = let
          base = removeAttrs rootTreeInfo [""];
          nopt = builtins.mapAttrs ( _: v:
            if v.optional then v else removeAttrs v ["optional"]
          ) base;
          ndev = builtins.mapAttrs ( _: v:
            if v.dev then v else removeAttrs v ["dev"]
          ) nopt;
        in ndev;
      }] else []
    ) ++ [../pdef];
  in builtins.mapAttrs proc plconf.config.plents;

  translatedPlents = rough;

  #translatedPlents = let
  #  addTreeInfo = plentKey: config: let
  #    treeInfo = removeAttrs ( lib.focusTree {
  #      treeInfo = rootTreeInfo;
  #      newRoot  = plentKey;
  #      inherit (
  #        ( lib.addPdefs ( builtins.attrValues rough ) ).config.floco
  #      ) pdefs;
  #    } ).treeInfo [""];
  #  in ( lib.evalModules {
  #    # Regenerates `_export'.
  #    modules = [
  #      { config = toPdef plentKey plconf.config.plents.${plentKey}; }
  #      { config.treeInfo = lib.mkForce treeInfo; }
  #      ../pdef
  #    ];
  #  } ).config;
  #  proc = plentKey: config:
  #    if ( plentKey == "" ) ||
  #       ( config.treeInfo != null ) ||
  #       config.lifecycle.build
  #    then builtins.deepSeq config config
  #    else ( let x = addTreeInfo plentKey config; in builtins.deepSeq x x );
  #in builtins.mapAttrs proc ( builtins.deepSeq rough rough );


# ---------------------------------------------------------------------------- #

  configs = builtins.concatLists ( builtins.attrValues translatedPlents );


# ---------------------------------------------------------------------------- #

in {

  inherit configs;
  packages = builtins.attrValues ( builtins.mapAttrs ( _: modules:
    ( lib.evalModules { inherit modules; } ).config
  ) ( lib.filterAttrs ( path: _:
    ( path == "" ) || ( lib.hasPrefix "node_modules" path )
  ) ( translatedPlents ) ) );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
