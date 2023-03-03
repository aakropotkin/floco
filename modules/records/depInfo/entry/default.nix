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

in lib.libfloco.depInfoBaseEntryDeferred // {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/depInfo/entry";

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
