# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, ...
}: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/records/pjsCore/module.nix";

  options.records = lib.mkOption {
    type = nt.submodule {
      options.pjsCore = lib.mkOption {
        type = nt.submodule ( { options, ... }: {

          options.module = lib.mkOption {
            description = lib.mdDoc ''
              The deferred form of a `pjsCore` record.
            '';
            type = nt.deferredModule;
          };

          options.mkOpt = lib.mkOption {
            description = lib.mdDoc ''
              Defines a `pjsCore` option.
            '';
            type = nt.raw;
          };

          config.mkOpt = lib.mkDerivedConfig options.module ( module:
            lib.mkOption {
              description = lib.mdDoc ''
                Project "manifest" information like those found in
                `package.json` and similar files, extended with `floco` specific
                "core" information such as `key` and `ident`.
              '';
              type = nt.submodule module;
            }
          );

        } );
      };
    };
  };

  config.records.pjsCore.module = ./record.nix;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
