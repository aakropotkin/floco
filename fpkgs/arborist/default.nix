# ============================================================================ #
#
# Package shim exposing installable targets from `floco` modules.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs      ? ( import ../../inputs ).nixpkgs.flake
, lib          ? import ../../lib { inherit (nixpkgs) lib; }
, system       ? builtins.currentSystem
, pkgsFor      ? nixpkgs.legacyPackages.${system}
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

in fmod.config.floco.packages."@npmcli/arborist"."6.1.5".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
