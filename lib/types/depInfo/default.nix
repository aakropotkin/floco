# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }:
     ( import ./base.nix { inherit lib; } )
  // ( import ./implementation.generic.nix { inherit lib; } )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
