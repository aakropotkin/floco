# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  lib = import ../../../lib {};

  fetcherModules = [
    ../../../modules/fetcher/interface.nix
    ../../../modules/fetchers/interface.nix
    ../../../modules/fetchers/implementation.nix
  ];

  defInput = { config, ... }: {
    options.input = lib.mkOption { type = config.fetchers.path.fetchInfo; };
  };

  mod = lib.evalModules {
    modules = fetcherModules ++ [
      defInput
      {
        config.input.path = ./.;
      }
    ];
  };

in removeAttrs mod.config.input ["filter"]


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
