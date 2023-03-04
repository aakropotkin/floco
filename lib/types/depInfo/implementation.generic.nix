# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  depInfoEntryGenericArgs = {
    lib
  , options
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
    # `package-lock.json' carries a top level `requires' field that is of type
    # `bool', so we coerce to an attrset.
    req    = if builtins.isAttrs requires then requires else {};
    rtDeps = req // optionalDependencies // dependencies;
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoEntryGenericArgs";
    # Needs to be lower-priority than top level `depInfo' usage of
    # `lib.mkDefault' to avoid clashing.
    _module.args = builtins.mapAttrs ( _: lib.mkOverride 1001 ) {
      ident = let
        len = builtins.length options._module.specialArgs.loc;
      in builtins.elemAt options._module.specialArgs.loc ( len - 2 );
      requires             = {};
      dependencies         = req;
      devDependencies      = {};
      devDependenciesMeta  = {};
      optionalDependencies = {};
      bundleDependencies   = false;
      bundledDependencies  =
        if bundleDependencies then builtins.attrNames rtDeps else [];
    };
  };


# ---------------------------------------------------------------------------- #

  depInfoEntryGenericImpl = {
    lib
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
    # `package-lock.json' carries a top level `requires' field that is of type
    # `bool', so we coerce to an attrset.
    req    = if builtins.isAttrs requires then requires else {};
    rtDeps = req // optionalDependencies // dependencies;
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoEntryGenericImpl";
    config = builtins.mapAttrs ( _: lib.mkDefault ) {

      descriptor = rtDeps.${ident} or devDependencies.${ident} or
                   optionalDependencies.${ident} or "*";

      runtime = ( rtDeps ? ${ident} ) || ( optionalDependencies ? ${ident} ) ||
                ( builtins.elem ident bundledDependencies );

      dev = ( rtDeps              ? ${ident} ) ||
            ( devDependencies     ? ${ident} ) ||
            ( devDependenciesMeta ? ${ident} );

      optional = ( optionalDependencies ? ${ident} ) ||
                 ( devDependenciesMeta.${ident}.optional or false );


      bundled = builtins.elem ident bundledDependencies;

    };
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    depInfoEntryGenericArgs
    depInfoEntryGenericImpl
  ;

  depInfoEntryGeneric = lib.types.submodule [
    lib.libfloco.depInfoBaseEntryDeferred
    lib.libfloco.depInfoEntryGenericArgs
    lib.libfloco.depInfoEntryGenericImpl
  ];

  depInfoGeneric = lib.libfloco.depInfoBaseWith [
    lib.libfloco.depInfoEntryGenericArgs
    lib.libfloco.depInfoEntryGenericImpl
  ];

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
