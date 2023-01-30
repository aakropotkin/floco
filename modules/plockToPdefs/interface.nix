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

  options.rootTreeInfo = lib.mkOption {
    type = nt.lazyAttrsOf (
      nt.submodule ../records/pdef/treeInfo/single.interface.nix
    );
    default = {};
  };

  options.pdefsByPath = lib.mkOption {
    type    = nt.lazyAttrsOf ( nt.submodule {} );
    default = {};
  };

  options.exports = lib.mkOption {
    type    = nt.lazyAttrsOf ( nt.lazyAttrsOf lib.libfloco.jsonValue );
    default = {};
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
