# ============================================================================ #
#
# A generic implementation of the `depInfo' record which takes "manifest"
# fields as arguments.
# Additionally this implementation accepts `requires' fields as found in
# `package-lock.json' to avoid what would otherwise be a mostly identical
# second implementation.
#
# ---------------------------------------------------------------------------- #
#
# This implementation can be consumed as individual deferred modules to improve
# reuse by extensions and other lib routines which may have need for them; but
# for readers: try to avoid getting lost in "complexity" here, the form you most
# likely want to use is `depInfoGenericMember[Deferred]',
# or `depInfoEntryGeneric'.
#
# Examples:
#
# { lib, config, ... }:
#
#   # As a member of submodule.
#   options.my-pkg = lib.mkOption {
#     type = nt.submodule [
#       lib.libfloco.depInfoGenericMemberDeferred
#       {
#         options.ident = lib.libfloco.mkIdentOption;
#         # Other Declarations...
#       }
#     ];
#     default = {};
#   };
#   config.my-pkg = {
#     # To translate manifest fields
#     _module.args.dependencies.lodash = "^4.17.21";
#     # To add explicit declarations.
#     # Notice that `depInfo' is a MEMBER of the `submodule'.
#     depInfo.bar.descriptor = "^6.6.6";
#   };
#
#  # As a single field submodule, containing only `depInfo'.
#  options.singleton = lib.mkOption {
#    type     = lib.libfloco.depInfoGenericMember;
#     default = {};
#  };
#  config.depInfo-singleton._module.args.dependencies.lodash = "^4.17.21";
#
#  # For a single entry.
#  options.depInfoEnt = lib.mkOption {
#    type = lib.libfloco.depInfoGeneric;
#  };
#  config.depInfoEnt = config.singleton.depInfo.lodash;
#
#
# ---------------------------------------------------------------------------- #
#
# XXX: Because args may depend on other args, you can't use `builtins.mapAttrs'
# to apply `lib.mkDefault' or similar overrides.
# The Nix evaluator is eager and will demand that the `let' above the
# `builtins.mapAttrs' be evaluated first, which causes infinite recursion.
#
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
    req = if builtins.isAttrs requires then requires else {};
    # Needs to be lower-priority than top level `depInfo' usage of
    # `lib.mkDefault' to avoid clashing.
    mkEntryDefault = lib.mkOverride 1001;
  in {
    _file = "<libfloco>/types/depInfo/implementation.generic.nix:" +
            "depInfoEntryGenericArgs";
    _module.args.ident =
      mkEntryDefault ( lib.libfloco.getModuleBaseName options );
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

    config._module.args.deserialized = lib.mkOptionDefault false;
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

  depInfoGenericMemberDeferred = {
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

    imports = [depInfoGenericArgs];

    options.depInfo = lib.mkOption {
      inherit (lib.libfloco.mkDepInfoBaseOptionWith {}) description;
      type = let
        fdes = if deserialized then [] else [
          lib.libfloco.depInfoEntryGenericArgs
          lib.libfloco.depInfoEntryGenericImpl
        ];
      in nt.attrsOf ( nt.submodule ( [
        lib.libfloco.depInfoBaseEntryDeferred
        {
          config._module.args =
            removeAttrs config._module.args [
              "deserialized" "idents" "extraEntryModules"
            ];
        }
      ] ++ fdes ++ ( lib.toList extraEntryModules ) ) );
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
    depInfoGenericMemberDeferred
  ;

  depInfoGenericMemberDeferredWith = {
    extraModules      ? []
  , extraEntryModules ? []
  }: {
    imports = [
      depInfoGenericMemberDeferred
      { config._module.args = { inherit extraEntryModules; }; }
    ] ++ extraModules;
  };

  depInfoGenericMember     = lib.types.submodule depInfoGenericMemberDeferred;
  depInfoGenericMemberWith = {
    extraModules      ? []
  , extraEntryModules ? []
  }: lib.types.submodule ( [
    depInfoGenericMemberDeferred
    { config._module.args = { inherit extraEntryModules; }; }
  ] ++ extraModules );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
