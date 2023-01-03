# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, config  ? {
    imports = [../../modules/top];
    config._module.args.pkgs = pkgsFor;
  }
}: let

# ---------------------------------------------------------------------------- #

  floco = lib.evalModules { modules = [config ./floco.nix]; };

# ---------------------------------------------------------------------------- #

in floco.config.flocoPackages.packages.which."2.0.2".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
