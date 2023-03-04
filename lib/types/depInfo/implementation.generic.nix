# ============================================================================ #
#
# XXX: For because args may depend on other args, you can't use
# `builtins.mapAttrs' to apply `lib.mkDefault' or similar overrides.
# The Nix evaluator is eager and will demand that the `let' above the
# `builtins.mapAttrs' be evaluated first, which causes infinite recursion.
#
# ---------------------------------------------------------------------------- #

{ lib } @ top: let

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
  , runtimeDeps
  , ...
  }: let
    # `package-lock.json' carries a top level `requires' field that is of type
    # `bool', so we coerce to an attrset.
    req            = if builtins.isAttrs requires then requires else {};
    mkEntryDefault = lib.mkOverride 1001;
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoEntryGenericArgs";
    # Needs to be lower-priority than top level `depInfo' usage of
    # `lib.mkDefault' to avoid clashing.
    _module.args.ident = let
      len = builtins.length options._module.specialArgs.loc;
      i   = builtins.elemAt options._module.specialArgs.loc ( len - 3 );
    in mkEntryDefault i;
    _module.args.requires             = mkEntryDefault {};
    _module.args.dependencies         = mkEntryDefault req;
    _module.args.devDependencies      = mkEntryDefault {};
    _module.args.devDependenciesMeta  = mkEntryDefault {};
    _module.args.optionalDependencies = mkEntryDefault {};
    _module.args.bundleDependencies   = mkEntryDefault false;
    _module.args.bundledDependencies  = mkEntryDefault (
      if bundleDependencies then builtins.attrNames runtimeDeps else []
    );
    _module.args.runtimeDeps = mkEntryDefault (
      req // optionalDependencies // dependencies
    );
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
  , runtimeDeps
  , ...
  }: {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoEntryGenericImpl";
    config = builtins.mapAttrs ( _: lib.mkDefault ) {

      descriptor = runtimeDeps.${ident} or devDependencies.${ident} or
                   optionalDependencies.${ident} or "*";

      runtime = ( runtimeDeps ? ${ident} ) ||
                ( optionalDependencies ? ${ident} ) ||
                ( builtins.elem ident bundledDependencies );

      dev = ( runtimeDeps              ? ${ident} ) ||
            ( devDependencies     ? ${ident} ) ||
            ( devDependenciesMeta ? ${ident} );

      optional = ( optionalDependencies ? ${ident} ) ||
                 ( devDependenciesMeta.${ident}.optional or false );

      bundled = builtins.elem ident bundledDependencies;

    };

  };


# ---------------------------------------------------------------------------- #

  depInfoGenericArgs = {
    lib
  , deserialized
  , requires
  , dependencies
  , devDependencies
  , devDependenciesMeta
  , optionalDependencies
  , bundleDependencies
  , bundledDependencies
  , runtimeDeps
  , idents
  , extraEntryModules
  , ...
  }: let
    nt = lib.types;
    # `package-lock.json' carries a top level `requires' field that is of type
    # `bool', so we coerce to an attrset.
    req    = if builtins.isAttrs requires then requires else {};
    raw    = runtimeDeps // devDependencies // devDependenciesMeta;
    mkEnt  = name: { inherit name; value = {}; };
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoGenericArgs";

    config._module.args.deserialized = lib.mkDefault false;
    config._module.args.requires     = lib.mkDefault {};
    # `package-lock.json' carries a top level `requires' field that is of type
    # `bool', so we coerce to an attrset.
    config._module.args.dependencies         = lib.mkDefault req;
    config._module.args.devDependencies      = lib.mkDefault {};
    config._module.args.devDependenciesMeta  = lib.mkDefault {};
    config._module.args.optionalDependencies = lib.mkDefault {};
    config._module.args.bundleDependencies   = lib.mkDefault false;
    config._module.args.bundledDependencies  = lib.mkDefault (
      if bundleDependencies then builtins.attrNames runtimeDeps else []
    );
    config._module.args.runtimeDeps = lib.mkDefault (
      req // optionalDependencies // dependencies
    );
    config._module.args.idents = lib.mkDefault (
      ( builtins.attrNames raw ) ++ ( raw.bundledDependencies or [] )
    );
    config._module.args.extraEntryModules = lib.mkOptionDefault [];

  };


# ---------------------------------------------------------------------------- #

  depInfoGenericMember = {
    lib
  , config
  , deserialized
  , requires
  , dependencies
  , devDependencies
  , devDependenciesMeta
  , optionalDependencies
  , bundleDependencies
  , bundledDependencies
  , runtimeDeps
  , idents
  , extraEntryModules
  , ...
  }: let
    nt    = lib.types;
    mkEnt = name: { inherit name; value = {}; };
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoGenericMemberInit";

    options.depInfo = lib.mkOption {
      inherit (lib.libfloco.mkDepInfoBaseOptionWith {}) description;
      type = let
        fdes = if deserialized then [] else [
          lib.libfloco.depInfoEntryGenericArgs
          lib.libfloco.depInfoEntryGenericImpl
        ];
      in nt.attrsOf ( nt.submodule [
        lib.libfloco.depInfoBaseEntryDeferred
        {
          config._module.args =
            removeAttrs config._module.args [
              "deserialized" "idents" "extraEntryModules"
            ];
        }
      ] ++ fdes ++ ( lib.toList extraEntryModules ) );
    };

    config.depInfo =
      lib.mkDefault ( builtins.listToAttrs ( map mkEnt idents ) );

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


# ---------------------------------------------------------------------------- #

  inherit
    depInfoGenericArgs
    depInfoGenericMember
  ;

  depInfoGenericMemberWith = {
    extraModules      ? []
  , extraEntryModules ? []
  }: lib.types.submoduleWith {
    modules = [
      depInfoGenericMember
      { config._module.args = { inherit extraEntryModules; }; }
    ] ++ extraModules;
  };

  depInfoGenericBareWith = {
    lib                    ? top.lib
  , deserialized           ? null
  , requires               ? null
  , dependencies           ? null
  , devDependencies        ? null
  , devDependenciesMeta    ? null
  , optionalDependencies   ? null
  , bundleDependencies     ? null
  , bundledDependencies    ? null
  , runtimeDeps            ? null
  , idents                 ? null
  , extraEntryModules      ? null
  , extraModules           ? []
  } @ args: let
    args' = removeAttrs ( lib.evalModules {
      modules = [
        depInfoGenericArgs
        { config._module.args = removeAttrs args ["extraModules"]; }
      ];
    } )._module.args ["extendModules" "moduleType"];
    nt = lib.types;
  in nt.submoduleWith {
    modules = let
      fdes = if args'.deserialized then [] else [
        lib.libfloco.depInfoEntryGenericArgs
        lib.libfloco.depInfoEntryGenericImpl
      ];
    in [
      {
        freeformType = nt.attrsOf ( nt.submodule ( [
          lib.libfloco.depInfoBaseEntryDeferred
          {
            config._module.args = removeAttrs args' [
              "deserialized" "idents" "extraEntryModules"
            ];
          }
        ] ++ fdes ++ ( lib.toList args'.extraEntryModules ) ) );
        config = let
          mkEnt = name: { inherit name; value = {}; };
        in builtins.listToAttrs ( map mkEnt args'.idents );
      }
    ] ++ ( lib.toList extraModules );
    specialArgs = args';
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
