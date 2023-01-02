# ============================================================================ #
#
# Interface for a single `depInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  # Additional bool fields may be added in association with various lifecycle
  # events such as `test', `lint', etc allowing users to minimize the trees
  # used for those events.
  freeformType = nt.attrsOf nt.bool;

  options = {

    descriptor = lib.mkOption {
      description = lib.mdDoc ''
        Descriptor indicating version range or exact source required to satisfy
        a dependency.
        
        The value `"*"` allows any version or source to be used, as long as it
        has the same identifier ( name ).
      '';
      type    = nt.str;
      default = "*";
    };

    pin = lib.mkOption {
      description = lib.mdDoc ''
        An exact version number or URI indicating the "resolved" form of a
        dependency descriptor.
        
        This will be used for `treeInfo` formation, and is available for usage
        by extensions to `floco`.
      '';
      type    = nt.nullOr nt.str;
      default = null;
    };

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

    bundled = lib.mkOption {
      description = lib.mdDoc ''
        Whether the dependency is distributed in registry tarballs alongside
        the consumer.

        This is sometimes used to include patched modules, but whenver possible
        bundling should be avoided in favor of tooling like `esbuild`
        or `webpack` because the effect bundled dependencies have on resolution
        is fraught.
      '';
      type    = nt.bool;
      default = false;
    };

    # Indicates whether the dependency is required for various preparation
    # phases or jobs.
    runtime = lib.mkOption {
      description = ''
        Whether the dependency is required at runtime.
        Other package management tools often refer to these as
        "production mode" dependencies.
      '';
      type    = nt.bool;
      default = false;
    };

    dev = lib.mkOption {
      description = ''
        Whether the dependency is required during pre-distribution phases.
        This includes common tasks such as building, testing, and linting.
      '';
      type    = nt.bool;
      default = true;
    };

  };  # End `options'

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
