# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

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
      type = nt.submodule {

        imports = [
          ./pdef/deferred.nix
          ./target
        ];

        options.depInfo = lib.mkOption {
          description = lib.mdDoc ''
            Abstract record used to represent dependency information.
          '';
          type = nt.submodule {

            options.serialize = lib.mkOption {
              description = lib.mdDoc ''
                Function which serializes a `depInfo` record.
              '';
              type    = nt.functionTo nt.raw;
              default = depInfo: import ./depInfo/serialize.nix {
                inherit lib depInfo;
              };
            };

            options.extraModules = lib.mkOption {
              description = lib.mdDoc ''
                Additional modules to be added to the `deferred` form of the
                `depInfo` extension.
              '';
              type    = nt.coercedTo nt.raw lib.toList ( nt.listOf nt.raw );
              default = [];
            };

            options.extraEntryModules = lib.mkOption {
              description = lib.mdDoc ''
                Additional modules to be added to the `deferred` form of
                `depInfo.<IDENT>` submodules/members.
              '';
              type    = nt.coercedTo nt.raw lib.toList ( nt.listOf nt.raw );
              default = [];
            };

            options.deferred = lib.mkOption {
              description = lib.mdDoc ''
                Deferred module which adds `depInfo` to a submodule.

                Note that this ADDS `depInfo` as a field to a module, it is not
                itself a "bare" `depInfo` record.

                You can extend this record and its entries using `extraModules`
                and `extraEntryModules`, or replace it entirely with a
                "from scratch" implementation.
              '';
              type    = nt.deferredModule;
              default = lib.libfloco.depInfoGenericMemberDeferred;
            };

          };
          default = {};
        };  # End `options.depInfo'

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
