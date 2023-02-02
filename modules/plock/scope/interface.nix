# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/plock/scope/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

    path = lib.mkOption {
      type = nt.addCheck nt.str ( s: ! ( lib.hasSuffix "node_modules" s ) );
    };

    direct = lib.mkOption {
      type     = nt.attrsOf lib.libfloco.version;
      readOnly = true;
    };

    inherited = lib.mkOption {
      type     = nt.attrsOf lib.libfloco.version;
      readOnly = true;
    };

    isRoot = lib.mkOption {
      type     = nt.bool;
      readOnly = true;
    };

    following = lib.mkOption {
      type = nt.attrsOf lib.libfloco.version;
      readOnly = true;
    };

    pins = lib.mkOption {
      type     = nt.attrsOf lib.libfloco.version;
      readOnly = true;
    };

    all = lib.mkOption {
      type     = nt.attrsOf lib.libfloco.version;
      readOnly = true;
    };

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
