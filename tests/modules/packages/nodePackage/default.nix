# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../../../inputs ).nixpkgs.flake
, lib     ? import ../../../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      ../../../../modules/top
      ./pdefs.nix ./foverrides.nix
      {
        config.floco.settings = {
          inherit system;
          nodePackage = pkgsFor.nodejs-18_x;
        };
      }
    ];
  };


# ---------------------------------------------------------------------------- #

in fmod.config.floco.packages."@floco/test"."4.2.0".global


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
