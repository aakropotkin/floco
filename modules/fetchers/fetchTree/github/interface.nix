# ============================================================================ #
#
# Arguments used to fetch a source tree from github.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTree/github/interface.nix";

  options.fetchTree_github = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[github]` fetcher";
    visible     = "shallow";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
