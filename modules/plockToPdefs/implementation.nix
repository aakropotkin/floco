# ============================================================================ #
#
#
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
  #, integrity
  #, sha1
  , link
  , hasInstallScript
  , gypfile
  , ...
  } @ plent: let
    pp    = lib.generators.toPretty {} plent;
    ltype = if plentKey == "" then "dir" else
            if lib.hasPrefix "." plentKey then "dir" else
            if link then "link" else
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
      };
    };

    metaFiles = {
      inherit lockDir plentKey;
      plent = plock.packages.${plentKey};
    } // ( if plentKey != "" then {} else { inherit plock; } );

    fsInfo = {
      inherit gypfile;
      dir = ".";
    };

    fetchInfo = if builtins.elem ltype ["dir" "link"] then {
      type = "path";
      path = lockDir + "/" + resolved;
    } else {  # TODO: `github'
      type = ltype;
      url  = resolved;
    };

    # TODO: lifecycle
  };


# ---------------------------------------------------------------------------- #

in {

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
