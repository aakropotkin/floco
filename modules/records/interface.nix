# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/interface.nix";

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
          ( { ... }: {
            imports = [
              ./pdef/deferred.nix
              ./pjsCore
              ./target
            ];
          } )
        ];
        specialArgs = { inherit lib; };
      };

      default = {};

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
