# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  lt = import ./types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/inputs/interface.nix";

  options.inputs = lib.mkOption { type = nt.lazyAttrsOf lt.input; };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #