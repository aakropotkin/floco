# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../lib {}, config ? {}, ... }: let

# ---------------------------------------------------------------------------- #

  stage0 = lib.evalModules {
    modules = [
      ./stage0.nix
      {
        config = builtins.intersectAttrs {
          settings = true;
          env      = true;
          inputs   = true;
        } config;
      }
    ];
  };


# ---------------------------------------------------------------------------- #

  stage1 = lib.evalModules {
    modules = [
      ./stage1.nix
      {
        config = builtins.intersectAttrs {
          settings = true;
          records  = true;
          fetchers = true;
          builders = true;
          utils    = true;
        } config;
      }
    ];
    specialArgs = {
      inherit (stage0.config.env) lib pkgs;
      inherit (stage0.config) env inputs;
    };
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    lib
    config
    stage0
    stage1
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
