# ============================================================================ #
#
# A single `depInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, options
, deserialized

, requires
, dependencies
, devDependencies
, devDependenciesMeta
, optionalDependencies
, bundleDependencies
, bundledDependencies
, ...
}: let

# ---------------------------------------------------------------------------- #

  nt   = lib.types;
  oloc = builtins.length options.depInfo.loc;

# ---------------------------------------------------------------------------- #

  req         = if builtins.isAttrs requires then requires else {};
  runtimeDeps = req // optionalDependencies // dependencies;
  raw         = runtimeDeps // devDependencies // devDependenciesMeta;
  idents      = ( builtins.attrNames raw ) ++ ( raw.bundledDependencies or [] );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/depInfo";

# ---------------------------------------------------------------------------- #

  options.depInfo = lib.mkOption {
    description = lib.mdDoc ''
      Information regarding dependency modules/packages.
      This record is analogous to the various
      `package.json:.[dev|peer|optional|bundled]Dependencies[Meta]` fields.

      These config settings do note necessarily dictate the contents of the
      `treeInfo` configs, which are used by builders, but may be used to provide
      information needed to generate trees if they are not defined.
    '';
    type = nt.attrsOf ( nt.submodule ( { options, ... }: {
      imports = [./entry];
      config._module.args = let
        comm = removeAttrs config._module.args ["deserialized"];
        inherit (options.descriptor) loc;
      in comm // { ident = lib.mkOptionDefault ( builtins.elemAt loc oloc ); };
    } ) );
    default = {};
  };


# ---------------------------------------------------------------------------- #

  config._module.args.deserialized         = lib.mkOptionDefault false;
  config._module.args.requires             = lib.mkOptionDefault {};
  config._module.args.dependencies         = lib.mkOptionDefault req;
  config._module.args.devDependencies      = lib.mkOptionDefault {};
  config._module.args.devDependenciesMeta  = lib.mkOptionDefault {};
  config._module.args.optionalDependencies = lib.mkOptionDefault {};
  config._module.args.bundleDependencies   = lib.mkOptionDefault false;
  config._module.args.bundledDependencies  = lib.mkOptionDefault (
    if bundleDependencies then builtins.attrNames runtimeDeps else []
  );


# ---------------------------------------------------------------------------- #

  config.depInfo = builtins.listToAttrs ( map ( name: {
    inherit name; value = {};
  } ) idents );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
