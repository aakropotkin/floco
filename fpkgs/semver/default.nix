# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs      ? ( import ../../inputs ).nixpkgs.flake
, lib          ? import ../../lib { inherit (nixpkgs) lib; }
, system       ? builtins.currentSystem
, pkgsFor      ? nixpkgs.legacyPackages.${system}
, nodePackage  ? pkgsFor.nodejs-18_x
, extraModules ? []
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      ../../modules/top
      ../../modules/configs/use-fetchzip.nix
      {
        config._module.args.pkgs = pkgsFor;
        config.floco.settings    = { inherit system; };
      }
      ./floco-cfg.nix
    ] ++ ( lib.toList extraModules );
  };


# ---------------------------------------------------------------------------- #

in fmod.config.floco.packages.semver."7.3.8".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
