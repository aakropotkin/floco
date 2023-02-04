# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.fetchers = lib.mkOption {
    type = nt.submoduleWith {
      modules = [
        ( { ... }: {
          _file = "<floco>/fetchers/implementation.nix";
          freeformType = nt.attrsOf ( nt.submodule {
            imports = [config.fetcher];
          } );
          imports = [
            ./path/implementation.nix
            ./fetchTree/implementation.nix
            ./fetchTarballDrv/implementation.nix
            ./composed/implementation.nix
          ];
        } )
      ];
    };
    default.config._module.args = {
      inherit (config) fetcher;
      pkgs = lib.mkDefault pkgs;
    };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
