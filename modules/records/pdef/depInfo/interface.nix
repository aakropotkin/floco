# ============================================================================ #
#
# Indicates information about dependencies of a package/module.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/depInfo/interface.nix";

# ---------------------------------------------------------------------------- #

  options.depInfo = lib.mkOption {
    description = lib.mdDoc ''
      Information regarding dependency modules/packages.
      This record is analogous to the various
      `package.json:.[dev|peer|optional|bundled]Dependencies[Meta]` fields.

      These config settings do note necessarily dictate the contents of the
      `treeInfo` configs, which are used by builders, but may be used to provide
      information needed to generate trees if they are not defined.
    '';
    type = nt.attrsOf ( nt.submodule ./single.interface.nix );
    default = {};
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
