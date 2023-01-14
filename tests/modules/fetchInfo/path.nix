# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  lib = import ../../../lib {};

  fetcherModules = [
    ../../../modules/fetchers/interface.nix
    ../../../modules/fetchers/implementation.nix
  ];

  defInput = { options, config, ... }: {
    options.input = lib.mkOption {
      type = lib.types.submodule {
        imports = [config.myFetchers.path];
      };
    };
  };

  mod = lib.evalModules {
    modules = fetcherModules ++ [
      ( { config, ... }: {
        options.myFetchers = lib.mkOption {
          type    = lib.types.submodule { imports = [config.fetchers]; };
          default = {};
        };
      } )
      defInput
      {
        config.input = {
          path = ./.;
        };
      }
    ];
  };

in mod.config


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
