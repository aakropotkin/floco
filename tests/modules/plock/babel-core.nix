# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  inherit (builtins.getFlake "nixpkgs") lib;

  pl2pdefs = import ../../../modules/plockToPdefs/implementation.nix {
    inherit lib;
    lockDir = toString ./.;
    plock   = lib.importJSON ./babel.core.package-lock.json;
  };

in map ( v: v._export ) pl2pdefs.packages


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #