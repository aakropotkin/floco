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

    pin = lib.libfloco.mkPinOption;

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

    # This field is redundant.
    # It is covered by `dev' and `optional' fields.
    # Arborist docs excplicitly mention this.
    # From what I can tell it is only used as a shorthand.
    #
    #devOptional = lib.mkOption {
    #  description =  lib.mdDoc ''
    #    Whether the dependency may be omitted from the `node_modules/` tree
    #    during post-distribution phases, but NOT during `pre-distribution`.

    #    For clarity, this means "I require this to build/test, but at runtime
    #    it is optional".

    #    Conventionally this is used to mark dependencies which are only required
    #    under certain conditions such as platform, architecture, or engines.
    #    Generally optional dependencies carry `sysInfo` conditionals, or
    #    `postinstall` scripts which must be allowed to fail without blocking
    #    the build of the consumer.
    #  '';
    #  type    = nt.bool;
    #  default = false;
    #};

  };  # End `options'


# ---------------------------------------------------------------------------- #

  config = let
    req         = if builtins.isAttrs requires then requires else {};
    runtimeDeps = req // optionalDependencies // dependencies;
    # Needs to be lower-priority than top level `depInfo' usage of
    # `lib.mkDefault' to avoid clashing.
    mkDefault' = lib.mkOverride 1001;
  in {

# ---------------------------------------------------------------------------- #

    _module.args.requires             = mkDefault' {};
    _module.args.dependencies         = mkDefault' req;
    _module.args.devDependencies      = mkDefault' {};
    _module.args.devDependenciesMeta  = mkDefault' {};
    _module.args.optionalDependencies = mkDefault' {};
    _module.args.bundleDependencies   = mkDefault' false;
    _module.args.bundledDependencies  = mkDefault' (
      if bundleDependencies then builtins.attrNames runtimeDeps else []
    );


# ---------------------------------------------------------------------------- #

    descriptor = lib.mkDefault (
      runtimeDeps.${ident} or devDependencies.${ident} or
      optionalDependencies.${ident} or "*"
    );

    runtime = lib.mkDefault (
      ( runtimeDeps ? ${ident} ) ||
      ( optionalDependencies ? ${ident} ) ||
      ( builtins.elem ident bundledDependencies )
    );

    dev = lib.mkDefault (
      ( runtimeDeps         ? ${ident} ) ||
      ( devDependencies     ? ${ident} ) ||
      ( devDependenciesMeta ? ${ident} )
    );

    optional = lib.mkDefault (
      ( optionalDependencies ? ${ident} ) ||
      ( devDependenciesMeta.${ident}.optional or false )
    );

    #devOptional = lib.mkDefault (
    #  devDependenciesMeta.${ident}.optional or false
    #);

    bundled = lib.mkDefault ( builtins.elem ident bundledDependencies );


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
