# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {

  _file = "<floco>/fetchers/composed/interface.nix";

  options.composed = lib.mkOption {
    description = lib.mdDoc ''
      Generic fetcher comprised of multiple sub-fetchers.
    '';
    visible = "shallow";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
