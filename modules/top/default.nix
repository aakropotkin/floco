# ============================================================================ #
#
# Top level `floco' module.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/top";

# ---------------------------------------------------------------------------- #

  options.floco = lib.mkOption {
    description = lib.mdDoc ''
      Scope used for configuring `floco` framework.
    '';
    type = nt.submoduleWith {
      modules = [
        ../settings
        ../records
        ../buildPlan
        ../pdefs
        ../packages
        ../fetchers
      ];
      specialArgs.lib =
        if lib ? libfloco then lib else import ../../lib { inherit lib; };
    };
    default = { config, ... }: {
      config._module.args.pkgs = let
        nixpkgs = ( import ../../inputs ).nixpkgs.flake;
        pkgsFor = nixpkgs.legacyPackages.${config.settings.system};
        withOv  = pkgsFor.extend ( import ../../overlay.nix );
      in lib.mkOverride 999 withOv;
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
