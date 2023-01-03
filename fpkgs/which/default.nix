# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? builtins.getFlake "nixpkgs"
, lib     ? nixpkgs.lib
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, config  ? {
    imports = [../../modules/packages];
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
