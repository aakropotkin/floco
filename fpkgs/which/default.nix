# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let

# ---------------------------------------------------------------------------- #

  floco = lib.evalModules {
    modules = [
      ../../modules/top
      { config._module.args.pkgs = pkgsFor; }
      ./floco-cfg.nix
    ];
  };

# ---------------------------------------------------------------------------- #

in floco.config.floco.packages.which."2.0.2".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
