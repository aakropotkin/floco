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

  # Drop the first package, being the "root" entry which is bogus.
  # Attempting to process it requires a `package.json' and processing `_export'
  # will also try looking up registry metadata unless we override.
  # To avoid all of that mess we just ignore the root.
in map ( v: v._export ) ( builtins.tail pl2pdefs.packages )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
