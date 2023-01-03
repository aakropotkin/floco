# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;
  ft = import ../../pdef/types.nix { inherit lib; };

in {

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    trees = lib.mkOption {
      type = nt.submodule {

        freeformType = nt.attrsOf nt.package;

# ---------------------------------------------------------------------------- #

        options.prod = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` tree used for `[pre|post]install` and "runtime" for
            globally installed packages.
          '';
          type    = nt.nullOr nt.package;
          default = null;
        };


# ---------------------------------------------------------------------------- #

        options.dev = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` tree used for pre-distribution phases such as build,
            lint, test, etc.
          '';
          type    = nt.nullOr nt.package;
          default = null;
        };


# ---------------------------------------------------------------------------- #

        options.supported = lib.mkOption {
          description = lib.mdDoc ''
            A filtered form of `treeInfo` which drops unsupported
            optional dependencies.
          '';
          default = null;
          type    = nt.nullOr ( nt.attrsOf ( nt.submoduleWith {
            shorthandOnlyDefinesConfig = true;
            # Should be identical to the definition of a `treeInfo' record,
            # except we drop the `optional' field.
            modules = [{
              freeformType = nt.attrsOf nt.bool;
              options.key = lib.mkOption {
                description = lib.mdDoc ''
                  Unique key used to refer to this package in `tree` submodules
                  and other `floco` configs, metadata, and structures.
                '';
                type = ft.key;
              };
              options.dev = lib.mkOption {
                description = ''
                  Whether the dependency is required ONLY during
                  pre-distribution phases.
                  This includes common tasks such as building, testing,
                  and linting.
                '';
                type    = nt.bool;
                default = false;
              };
            }];
          } ) );
        };


# ---------------------------------------------------------------------------- #

      };  # End `options.trees.type.options'

      default = {
        supported = null;
        prod      = null;
        dev       = null;
      };

    };  # End `options.trees'


# ---------------------------------------------------------------------------- #

  };  # End `options'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
