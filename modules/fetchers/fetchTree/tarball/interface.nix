# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTree/tarball/interface.nix";

  options.fetchTree_tarball = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[tarball]` args";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
