# ============================================================================ #
#
# A single `depInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib
, ident
, requires
, dependencies
, devDependencies
, devDependenciesMeta
, optionalDependencies
, bundleDependencies
, bundledDependencies
, ...
}: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/depInfo/entry";

# ---------------------------------------------------------------------------- #

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

        In the case of conflicts, the "latest" version will be used.
        The sorting algorithm prefers pre-releases over a release of the same
        version, following the behavior of `nix-env -u`.
        Read that again.

        TODO: Write a sort that makes more sense.
        Honestly though this is a rare edge case in properly
        maintained software.
      '';
      default = null;
      type    = let
        base = nt.nullOr lib.libfloco.version;
      in base // {
        merge = loc: defs: let
          values = lib.getValues defs;
          nnull  = builtins.filter ( x: x != null ) values;
          cmp    = a: b: ( builtins.compareVersions a b ) < 0;
        in if ( builtins.length values ) == 1 then builtins.head values else
           if ( builtins.length nnull ) == 0 then null else
           if ( builtins.length nnull ) == 1 then builtins.head nnull else
           builtins.head ( builtins.sort cmp nnull );
      };
    };

    optional = lib.mkOption {
      description =  lib.mdDoc ''
        Whether the dependency may be omitted from the `node_modules/` tree
        during post-distribution phases.

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

    devOptional = lib.mkOption {
      description =  lib.mdDoc ''
        Whether the dependency may be omitted from the `node_modules/` tree
        during pre-distribution phases.

        Conventionally this is used to mark dependencies which are only required
        under certain conditions such as platform, architecture, or engines.
        Generally optional dependencies carry `sysInfo` conditionals, or
        `postinstall` scripts which must be allowed to fail without blocking
        the build of the consumer.
      '';
      type    = nt.bool;
      default = false;
    };

  };  # End `options'


# ---------------------------------------------------------------------------- #

  config = let
    runtimeDeps = requires // optionalDependencies // dependencies;
  in {

# ---------------------------------------------------------------------------- #

    _module.args.requires             = lib.mkDefault {};
    _module.args.dependencies         = lib.mkDefault requires;
    _module.args.devDependencies      = lib.mkDefault {};
    _module.args.devDependenciesMeta  = lib.mkDefault {};
    _module.args.optionalDependencies = lib.mkDefault {};
    _module.args.bundleDependencies   = lib.mkDefault false;
    _module.args.bundledDependencies  = lib.mkDefault (
      if bundleDependencies then builtins.attrNames runtimeDeps else []
    );


# ---------------------------------------------------------------------------- #

    descriptor = runtimeDeps.${ident} or devDependencies.${ident} or
                 optionalDependencies.${ident} or "*";

    runtime = ( runtimeDeps ? ${ident} ) ||
              ( builtins.elem ident bundledDependencies );

    dev = ( runtimeDeps         ? ${ident} ) ||
          ( devDependencies     ? ${ident} ) ||
          ( devDependenciesMeta ? ${ident} );

    optional = optionalDependencies ? ${ident};

    devOptional = devDependenciesMeta.${ident}.optional or false;

    bundled = builtins.elem ident bundledDependencies;


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
