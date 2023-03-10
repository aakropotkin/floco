# ============================================================================ #
#
# Arguments used to fetch a file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTree/file/interface.nix";

  options.fetchTree_file = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[file]` args";
    visible     = "shallow";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
