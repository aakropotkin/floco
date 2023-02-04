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

  _file = "<floco>/buildPlan/interface.nix";

  options.buildPlan = lib.mkOption {
    description = lib.mdDoc ''
      Functions and metadata associated with build planning.
    '';
    type = nt.submodule {
      options.deriveTreeInfo = lib.mkOption {
        description = lib.mdDoc ''
          Whether `floco` should attempt to derive `<pdef>.treeInfo` records
          from pinned `<pdef>.depInfo.*.pin` fields.

          This option should not be enabled if the build plan contains
          dependency cycles, unless explicit `treeInfo` records have been
          provided forall cycle memebers.
        '';
        type    = nt.bool;
        default = false;
      };
    };
    default = {};
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
