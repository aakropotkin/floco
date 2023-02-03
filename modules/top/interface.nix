# ============================================================================ #
#
# Top level `floco' module.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/top/interface.nix";

# ---------------------------------------------------------------------------- #

  options.floco = lib.mkOption {
    description = lib.mdDoc ''
      Scope used for configuring `floco` framework.
    '';
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = false;
      modules = [
        ../buildPlan/interface.nix
        ../topo/interface.nix
        ../records/interface.nix
        ../pdefs/interface.nix
        ../packages/interface.nix
        ../fetcher/interface.nix
        ../fetchers/interface.nix
      ];
      specialArgs.lib =
        if lib ? libfloco then lib else import ../../lib { inherit lib; };
    };
    default = {};
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
