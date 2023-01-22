# ============================================================================ #
#
# Arguments used to fetch a source tree using `git'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTree/git/interface.nix";

  options.fetchTree_git = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[git]` fetcher";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
