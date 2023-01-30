# ============================================================================ #
#
# Produces a `pdef' record from the default pipeline, pulling metadata from the
# NPM registry.
#
# ---------------------------------------------------------------------------- #

let
  nixpkgs = ( import ../../../inputs ).nixpkgs.flake;
  system  = builtins.currentSystem;
  lib     = import ../../../lib { inherit (nixpkgs) lib; };
in ( lib.evalModules {
  modules = [
    ../../../modules/records/pdef
    {
      ident   = "lodash";
      version = "4.17.21";
      _module.args.pkgs =
        nixpkgs.legacyPackages.${system}.extend ( import ../../../overlay.nix );
    }
  ];
} ).config._export


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
