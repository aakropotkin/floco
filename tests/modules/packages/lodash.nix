# ============================================================================ #
#
# Tests evaluation of a package set, which just contains `lodash@4.17.21'.
#
# This essentially exists to force evaluation of all submodules.
#
# Run with:  nix eval --impure --json -f ./lodash.nix --apply 'f: f {}';
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../../../lib {} }: let

# ---------------------------------------------------------------------------- #

  module = lib.evalModules {
    modules = [
      ../../../modules/top
      {
        config.floco.pdefs.lodash."4.17.21" = {
          ident   = "lodash";
          version = "4.17.21";
        };
      }
    ];
  };
  lodash = module.config.floco.packages.lodash."4.17.21".pdef;

# ---------------------------------------------------------------------------- #

in lodash._export


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
