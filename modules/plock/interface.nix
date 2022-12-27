# ============================================================================ #
#
# Typed representation of a `package-lock.json(v2/3)' file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options = {

    plock   = lib.mkOption { type = nt.attrsOf nt.anything; };
    lockDir = lib.mkOption { type = nt.path; };
    plents  = lib.mkOption {
      type = nt.attrsOf ( import ./types.nix { inherit lib; } ).plent;
    };
    lockfileVersion = lib.mkOption { type = nt.int; };

  };  # End `options'

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
