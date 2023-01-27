# ============================================================================ #
#
# Interface used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTarball/interface.nix";

  options.fetchTarball = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTarball` abstraction";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
