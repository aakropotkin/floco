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

# ---------------------------------------------------------------------------- #

  _file = "<floco>/topo/interface.nix";

# ---------------------------------------------------------------------------- #

  options.topo = lib.mkOption {
    description = lib.mdDoc ''
      Functions and metadata associated with topologically sorting build plans.
    '';
    type = nt.submodule {

      options.toposortNoPins = lib.mkOption {
        description = lib.mdDoc ''
          A function which topologically sorts a list of `pdef` records.

          Package versions are ignored entirely - dependency relationships are
          established strictly by matching `name` values to `dependencies`,
          `optionalDependencies`, and `devDependencies` keys.
        '';
        type    = nt.functionTo lib.libfloco.toposorted;
        visible = "shallow";
      };

      options.toposortPins = lib.mkOption {
        description = lib.mdDoc ''
          A function which topologically sorts a list of `pdef` records.

          Package versions are matched using `<pdef>.depInfo.*.pin` fields.
          It is an error to call this function with missing `pin` values on
          ANY `pdef` records.
        '';
        type   = nt.functionTo lib.libfloco.toposorted;
       visible = "shallow";
      };

      options.toposortedAll = lib.mkOption {
        description = lib.mdDoc ''
          A toposorted form of all `floco.pdefs` records.

          This routine is expected to run slowly and should be
          referenced sparingly.
          Ideally you should only refer to this when optimizing build plans to
          be rewritten to disk.

          This routine uses `toposortNoPins` if all `pdef` records have a single
          version, or `toposortPins` if multiple versions exist.
          It is an error to reference this value if these restrictions are
          not met.
        '';
       type    = lib.libfloco.toposorted;
       visible = "shallow";
      };

      options.pdefsHaveSingleVersion = lib.mkOption {
        type     = nt.bool;
        readOnly = true;
        internal = true;
        visible  = false;
      };

      options.pdefsHavePins = lib.mkOption {
        type     = nt.bool;
        readOnly = true;
        internal = true;
        visible  = false;
      };

    };
    default = {};
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
