# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/top/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.floco = lib.mkOption {
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = false;
      modules = [
        ( { ... }: {
          imports = [
            ../topo/implementation.nix
            ../records/implementation.nix
            ../pdefs/implementation.nix
            ../packages/implementation.nix
            ../fetchers/implementation.nix
          ];
          config._module.args.pkgs = lib.mkDefault pkgs;
        } )
      ];
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
