# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  lib = import ../../../lib {};

  pl2pdefs = import ../../../modules/plockToPdefs/implementation.nix {
    inherit lib;
    lockDir = toString ./.;
    plock   = lib.importJSON ./babel.core.package-lock.json;
  };

in pl2pdefs.exports


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
