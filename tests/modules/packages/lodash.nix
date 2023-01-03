# ============================================================================ #
#
# Tests evaluation of default package set, which ( at time of writing ) just
# contains `lodash@4.17.21'.
#
# This essentially exists to force evaluation of all submodules.
#
# XXX: In the future if the default package set is removed, you can simply
# inline the old declaration here.
#
# Run with:  nix eval --impure --json -f ./lodash.nix --apply 'f: f {}';
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../../inputs ).nixpkgs.flake
, lib     ? ( import ../../../lib { inherit (nixpkgs) lib; } )
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let

# ---------------------------------------------------------------------------- #

  module = lib.evalModules {
    modules = [
      ../../../modules/packages
      { config._module.args.pkgs = pkgsFor; }
    ];
  };
  lodash = module.config.flocoPackages.packages.lodash."4.17.21".pdef;

# ---------------------------------------------------------------------------- #

in lodash._export

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
