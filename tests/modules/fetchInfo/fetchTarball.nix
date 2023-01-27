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
          type = config.fetchers.fetchTarball.fetchInfo;
        };
        config.input.url =
          "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";

        config.fetchers.fetchTarball.serializerHashKey = "sha256";
        config.fetchers.fetchTarball.serializerStyle   = "string";

      } )
    ];
  };

in mod.config.input


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
