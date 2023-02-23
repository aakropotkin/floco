# ============================================================================ #
#
# This is an extensible form of the standard `pjsCore' module found in
# `lib.libfloco' which has been provided for users to inject normalization and
# other transformations into translators.
#
# Most users will not need to use these options, since the standard `pjsCore'
# module is sufficient for most purposes.
# But for the 1% of users who need to do something special, this module is
# a powerful avenue for extension.
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
            type    = nt.deferredModule;
            default = ../../../lib/types/pjsCore/submodule.nix;
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

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
