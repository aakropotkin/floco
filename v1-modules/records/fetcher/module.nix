# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/records/fetcher";

  options.records = lib.mkOption {
    type = nt.submodule {
      options.fetcher = lib.mkOption {
        type = nt.submodule ( { options, ... }: {

          options.module = lib.mkOption {
            description = lib.mdDoc ''
              The deferred form of a `fetcher` record.
            '';
            type = nt.deferredModule;
          };

          options.mkOpt = lib.mkOption {
            description = lib.mdDoc ''
              Defines a `fetcher` option taking `name` as an argument to be used
              in the option description.
            '';
            type = nt.raw;
          };

          config.mkOpt = lib.mkDerivedConfig options.module ( module: name:
            lib.mkOption {
              description = lib.mdDoc ''
                An abstract form of `${name}` wrapped to implement the
                `fetcher` interface.
              '';
              type = nt.submodule module;
            } );

        } );
      };
    };
  };

  config.records.fetcher.module = ./record.nix;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
