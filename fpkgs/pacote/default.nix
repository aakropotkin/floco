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

  fmod = lib.evalModules {
    modules = [
      ../../modules/top
      { config._module.args.pkgs = pkgsFor; }
      ./floco-cfg.nix
    ];
  };

# ---------------------------------------------------------------------------- #

in fmod.config.floco.packages.pacote."13.3.0".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
