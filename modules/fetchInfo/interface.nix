# ============================================================================ #
#
# A `options.floco.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {
  inherit (import ./interfaces.nix { inherit lib; }) fetchInfo;
}
