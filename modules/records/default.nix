# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records";

# ---------------------------------------------------------------------------- #

  imports = [../fetchers];

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    records = lib.mkOption {
      description = lib.mdDoc ''
        Abstract records used to construct instances of common submodule types.

        These base interface must be implemented, but the implementations
        themselves may be swapped or overridden.
      '';
      type = nt.submoduleWith {
        modules = [
          ./pdef/deferred.nix
          ./pjsCore
        ];
        specialArgs = { inherit lib; };
      };
      default = {
        config._module.args.pkgs  = lib.mkDefault pkgs;
        config._module.args.floco = lib.mkDefault config;
      };
    };


# ---------------------------------------------------------------------------- #


  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
