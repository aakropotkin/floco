# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs      ? ( import ../../inputs ).nixpkgs.flake
, lib          ? import ../../lib { inherit (nixpkgs) lib; }
, system       ? builtins.currentSystem
, pkgsFor      ? nixpkgs.legacyPackages.${system}
, nodePackage  ? pkgsFor.nodejs
, extraModules ? []
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      ../../modules/top
      ../../modules/configs/use-fetchzip.nix
      {
        config._module.args.pkgs = pkgsFor;
        config.floco.settings    = { inherit system nodePackage; };
      }
      ./floco-cfg.nix
    ] ++ ( lib.toList extraModules );
  };


# ---------------------------------------------------------------------------- #

in fmod.config.floco.packages.pacote."13.3.0".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
