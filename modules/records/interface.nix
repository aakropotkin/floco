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

# ---------------------------------------------------------------------------- #

            imports = [
              ./pdef/deferred.nix
              ./pjsCore
              ./target
            ];


# ---------------------------------------------------------------------------- #

            options.depInfo = lib.mkOption {
              description = lib.mdDoc ''
                Abstract record used to represent dependency information.
              '';
              type = nt.submodule {
                options.deferred = lib.mkOption {
                  description = lib.mdDoc ''
                    Deferred module which adds `depInfo` to a submodule.
                  '';
                  type    = nt.deferredModule;
                  default = ./depInfo;
                };
                options.serialize = lib.mkOption {
                  description = lib.mdDoc ''
                    Function which serializes a `depInfo` record.
                  '';
                  type    = nt.functionTo nt.raw;
                  default = depInfo: import ./depInfo/serialize.nix {
                    inherit lib depInfo;
                  };
                };
              };
              default = {};
            };  # End `options.depInfo'


# ---------------------------------------------------------------------------- #

          } )
        ];
        specialArgs = { inherit lib; };
      };
    };  # End `options.records'


# ---------------------------------------------------------------------------- #


  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
