# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, pkgs
, config
, lockDir
, ylock   ? null
, ...
} @ args: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  ylock = let
    drv = derivation {
      name = "yarn-lock.json";
      src  = builtins.path {
        path      = lockDir + "/yarn.lock";
        recursive = false;
      };
      PATH    = "${pkgs.yaml2json}/bin";
      builder = "${pkgs.bash}/bin/bash";
      args    = ["-eu" "-o" "pipefail" "-c" ''
        yaml2json < "$src" > "$out";
      ''];
      inherit (pkgs) system;
      preferLocalBuild = true;
      allowSubstitutes = ( builtins.currentSystem or "unknown" ) != pkgs.system;
    };
  in if ( args.ylock or null ) != null then args.ylock else
     lib.importJSON drv.outPath;


# ---------------------------------------------------------------------------- #

  # FIXME: `version: 0.0.0-use.local' gets written for workspace members.
  mkEnt = descs: config: let
    m     = builtins.match "((@[^@/]+/)?[^@/]+)@.*" config.resolution;
    ident = builtins.head m;
  in {
    inherit ident;
    key         = ident + "/" + config.version;
    descriptors = lib.splitString ", " descs;
  } // config;


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/ylock/implementation.nix";

# ---------------------------------------------------------------------------- #

  config = {
    _module.args.ylock = lib.mkDefault null;
    inherit lockDir;
  };

  imports = [{
    _file  = lockDir + "/yarn.lock";
    config = {
      inherit ylock;
      lockfileVersion = ylock.__metadata.version;
      ylents = builtins.mapAttrs mkEnt ( removeAttrs ylock ["__metadata"] );
    };
  }];


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
