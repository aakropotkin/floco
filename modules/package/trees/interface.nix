# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/trees/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    trees = lib.mkOption {
      description = lib.mdDoc ''
        Stashes `node_modules/` trees used for lifecycle events.
        These are used to populate defaults for `lint.tree`, `built.tree`,
        `install.tree`, `test.tree`, etc.
      '';
      type = nt.submodule {

        freeformType = nt.attrsOf ( nt.nullOr nt.package );

# ---------------------------------------------------------------------------- #

        options.prod = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` tree used for `[pre|post]install` and "runtime" for
            globally installed packages.
            NOTE: The final tree used for a lifecycle event is set in the
            `<EVENT>.tree` option - this option is a commonly used as the
            default value for those trees, or as a base to be modified.
          '';
          type    = nt.nullOr nt.package;
          default = null;
        };


# ---------------------------------------------------------------------------- #

        options.dev = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` default tree used for pre-distribution phases such
            as build, lint, test, etc.
            NOTE: The final tree used for a lifecycle event is set in the
            `<EVENT>.tree` option - this option is a commonly used as the
            default value for those trees, or as a base to be modified.
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
              options.key = lib.mkKeyOption;
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
