# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  lib = import ../../../lib {};

  mod = lib.evalModules {
    modules = [
      ../../../modules/fetchers
      ( { config, ... }: {
        options.input = lib.mkOption {
          type = config.fetchers.fetchTarballDrv.fetchInfo;
        };
        config.input.url =
          "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";

        config.fetchers.fetchTarball.serializerStyle = "string";

      } )
    ];
  };

in mod.config.input


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
