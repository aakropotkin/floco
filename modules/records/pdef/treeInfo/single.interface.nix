# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/treeInfo/single.interface.nix";

# ---------------------------------------------------------------------------- #

  # Arbitrary booleans can be added to indicate when a tree member is only
  # required for certain lifecycle events.
  freeformType = nt.attrsOf nt.bool;

  options = {

# ---------------------------------------------------------------------------- #

    key = lib.mkKeyOption;


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

    link = lib.mkOption {
      description =  lib.mdDoc ''
        Whether the dependency can by symlinked into `node_modules/`.

        When symlinks are enabled the `global` target for a package must be
        defined, and its `<global>/lib/node_modules` directory contents will
        be symlinked into the consumer's `node_modules/` directory.

        When symlinks are enabled it is an error to declare any subpaths in
        `treeInfo` under a "linked" dependency.
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
