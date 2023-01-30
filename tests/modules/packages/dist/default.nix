# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../../../inputs ).nixpkgs.flake
, lib     ? import ../../../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ?
  nixpkgs.legacyPackages.${system}.extend ( import ../../../../overlay.nix )
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      ../../../../modules/top
      ./floco-cfg.nix
      { config._module.args.pkgs = pkgsFor; }
    ];
  };

# ---------------------------------------------------------------------------- #

in fmod.config.floco.packages."@floco/test"."4.2.0".dist


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
