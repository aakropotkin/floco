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
, plock   ? lib.importJSON "${lockDir}/package-lock.json"
, ...
}: let

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
            if lib.hasPrefix "." plentKey then "dir" else
            if lib.hasPrefix "git+" resolved then "git" else
            if lib.hasPrefix "https" resolved then "file" else
            throw "Unable to derived lifecycle type from entry: '${pp}'.";
  in {
    inherit ident version key ltype;
    binInfo.binPairs = bin;

    sysInfo = { inherit os cpu engines; };

    depInfo = import ../pdef/depinfo.implementation.nix {
      inherit lib;
      config = {
        inherit
          dependencies
          devDependencies
          devDependenciesMeta
          peerDependencies
          peerDependenciesMeta
          optionalDependencies
          requires
        ;
        # We intentionally ignore `dev', `peer', and `optional' fields.
      };
    };

    metaFiles = {
      inherit lockDir plentKey;
      plent = plock.packages.${plentKey};
    } // ( if plentKey != "" then {} else { inherit plock; } );

    fsInfo = { inherit gypfile; dir = "."; };

    fetchInfo = let
      # Locks `fetchInfo'
      fii = import ../fetchInfo/implementations.nix { inherit lib; };
    in if builtins.elem ltype ["dir" "link"] then {
      path = if resolved == "." then lockDir else lockDir + ( "/" + resolved );
    } else fii.fetchTree.any {  # TODO: `github'
      config.type = if ltype == "file" then "tarball" else "git";
      config.url  = resolved;
    };

    # TODO: lifecycle
  };


# ---------------------------------------------------------------------------- #

  translatedPlents = let
    proc = plentKey: plentRaw: ( lib.evalModules {
      modules = [../pdef ( toPdef plentKey plentRaw )];
    } ).config;
  in builtins.mapAttrs proc plconf.config.plents;


# ---------------------------------------------------------------------------- #

  # `treeInfo' for root package
  treeInfo = let
    asKeys   = builtins.mapAttrs ( _: v: v.key );
    devPaths = let
      attrs = lib.filterAttrs ( _: v: v.dev or false ) plock.packages;
    in builtins.attrNames attrs;
    dev = asKeys ( removeAttrs translatedPlents [""] );
  in {
    inherit dev;
    prod = removeAttrs dev devPaths;
  };


# ---------------------------------------------------------------------------- #

in {

  packages = let
    withTreeInfo = translatedPlents // {
      "" = translatedPlents."" // {
        inherit treeInfo;
        _export = translatedPlents.""._export // { inherit treeInfo; };
      };
    };
  in builtins.attrValues withTreeInfo;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
