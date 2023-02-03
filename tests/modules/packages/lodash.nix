# ============================================================================ #
#
# Tests evaluation of a package set, which just contains `lodash@4.17.21'.
#
# This essentially exists to force evaluation of all submodules.
#
# Run with:  nix eval --impure --json -f ./lodash.nix --apply 'f: f {}';
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../../inputs ).nixpkgs.flake
, lib     ? import ../../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ?
  nixpkgs.legacyPackages.${system}.extend ( import ../../../overlay.nix )
}: let

# ---------------------------------------------------------------------------- #

  module = lib.evalModules {
    modules = [
      ../../../modules/top
      {
        config.floco.pdefs.lodash."4.17.21" = {
          ident   = "lodash";
          version = "4.17.21";
        };
        config._module.args.pkgs = pkgsFor;
      }
    ];
  };

# ---------------------------------------------------------------------------- #

in module.config.floco.packages.lodash."4.17.21".key


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
