# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = lib.libfloco or ( lib.extend ../../lib/overlay.lib.nix ).libfloco;

# ---------------------------------------------------------------------------- #

in {

  input = nt.submodule {
    options.id         = lib.mkOption { type = nt.str; };
    options.uri        = lib.mkOption { type = nt.str; };
    options.flake      = lib.mkOption { type = nt.raw; };
    options.tree       = lib.mkOption { type = nt.lazyAttrsOf ft.jsonValue; };
    options.locked     = lib.mkOption { type = nt.lazyAttrsOf ft.jsonValue; };
    options.__toString = lib.mkOption {
      type    = nt.functionTo nt.str;
      default = self: self.uri;
    };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
