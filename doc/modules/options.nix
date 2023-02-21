# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}.extend ( import ../../overlay.nix )
}: let
  inherit ( lib.evalModules {
    modules = [
      {
        config._module.args.pkgs = pkgsFor;
        config.floco.settings    = { inherit system; };
        config.floco.pdefs.lodash."4.17.21" = {
          ident    = "lodash";
          version  = "4.17.21";
        };
      }
      ../../modules/top
    ];
    specialArgs = { inherit lib; };
  } ) options;
in removeAttrs options ["_module"]


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
