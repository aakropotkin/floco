# ============================================================================ #
#
# Interface used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/fetcher/fetchTarballDrv/interface.nix";

  options.fetchTarballDrv = lib.mkOption {
    description = lib.mdDoc "Derivation form of `nixpgkgs.fetchzip`.";
    visible     = "shallow";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
