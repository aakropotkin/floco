# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;
  ft = { inherit (lib.libfloco) ident version ltype key; };

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdef/treeInfo/single.interface.nix";

# ---------------------------------------------------------------------------- #

  # Arbitrary booleans can be added to indicate when a tree member is only
  # required for certain lifecycle events.
  freeformType = nt.attrsOf nt.bool;

  options = {

# ---------------------------------------------------------------------------- #

    key = lib.mkOption {
      description = lib.mdDoc ''
        Unique key used to refer to this package in `tree` submodules and other
        `floco` configs, metadata, and structures.
      '';
      type    = nt.nullOr ft.key;
      default = null;
    };


# ---------------------------------------------------------------------------- #

    dev = lib.mkOption {
      description = ''
        Whether the dependency is required ONLY during pre-distribution phases.
        This includes common tasks such as building, testing, and linting.
      '';
      type    = nt.bool;
      default = false;
    };


# ---------------------------------------------------------------------------- #

    optional = lib.mkOption {
      description =  lib.mdDoc ''
        Whether the dependency may be omitted from the `node_modules/` tree.

        Conventionally this is used to mark dependencies which are only required
        under certain conditions such as platform, architecture, or engines.
        Generally optional dependencies carry `sysInfo` conditionals, or
        `postinstall` scripts which must be allowed to fail without blocking
        the build of the consumer.
      '';
      type    = nt.bool;
      default = false;
    };


# ---------------------------------------------------------------------------- #


  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
