# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let
  inherit ( lib.evalModules {
    modules = [
      { config._module.args.pkgs = pkgsFor; }
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
