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
          type = config.fetchers.fetchTree_file.fetchInfo;
        };
        config.input.url =
          "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
      } )
    ];
  };

in mod.config.input


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
