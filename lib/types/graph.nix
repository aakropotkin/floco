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

  toposorted = nt.submodule ( { config, ... }: {
    options.result = lib.mkOption {
      type    = nt.nullOr ( nt.listOf nt.anything );
      default = null;
    };
    options.cycle  = lib.mkOption {
      type    = nt.listOf nt.anything;
      default = [];
    };
    options.loops = lib.mkOption {
      type    = nt.listOf nt.anything;
      default = [];
    };
    options.isDAG = lib.mkOption {
      type = nt.bool;
    };
    config.isDAG = config.cycle == [];
  } );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
