# ============================================================================ #
#
# Interface for a single `depInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options = {
    descriptor = lib.mkOption { type = nt.str; default = "*"; };
    pin = lib.mkOption {
      type    = nt.nullOr nt.str;
      default = null;
    };

    optional = lib.mkOption { type = nt.bool; default = false; };
    bundled  = lib.mkOption { type = nt.bool; default = false; };

    # Indicates whether the dependency is required for various preparation
    # phases or jobs.
    runtime = lib.mkOption { type = nt.bool; default = true; };
    dev     = lib.mkOption { type = nt.bool; default = false; };
    test    = lib.mkOption { type = nt.bool; default = false; };
    lint    = lib.mkOption { type = nt.bool; default = false; };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
