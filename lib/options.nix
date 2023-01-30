# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  mergePreferredOption = { compare }: loc: defs:
    builtins.head ( builtins.sort compare ( lib.getValues defs ) );


# ---------------------------------------------------------------------------- #

  mergeRelativePathOption = loc: defs: let
    toVal = { file, value, ... } @ def: let
      fp = if builtins.isPath file then toString file else file;
      rp = if builtins.pathExists ( fp + "/." ) then fp else dirOf fp;
    in if builtins.isPath value then value else
       if lib.isAbspath value
       then /. + ( builtins.unsafeDiscardStringContext value )
       else /. + ( rp + ( "/" + value ) );
    fixupDef = def: def // { value = toVal def; };
    fixed    = map fixupDef defs;
  in lib.mergeEqualOption loc fixed;


# ---------------------------------------------------------------------------- #

  mkKeyOption = lib.mkOption {
    description = lib.mdDoc ''
      Unique key used to refer to this package in `tree` submodules and other
      `floco` configs, metadata, and structures.
    '';
    type    = lib.libfloco.key;
    example = "@floco/test/4.2.0";
  };


# ---------------------------------------------------------------------------- #

  mkIdentOption = lib.mkOption {
    description = lib.mdDoc ''
      Package identifier/name as found in `package.json:.name`.
    '';
    type    = lib.libfloco.ident;
    example = "@floco/foo";
  };


# ---------------------------------------------------------------------------- #

  mkVersionOption = lib.mkOption {
    description = lib.mdDoc ''
      Package version as found in `package.json:.version`.
    '';
    type    = lib.libfloco.version;
    example = "4.2.0";
  };


# ---------------------------------------------------------------------------- #

  mkLtypeOption = lib.mkOption {
    description = lib.mdDoc ''
      Package "lifecycle type"/"pacote source type".
      This option effects which lifecycle events may run when preparing a
      package/module for consumption or installation.

      For example, the `file` ( distributed tarball ) lifecycle does not run
      any `scripts.[pre|post]build` phases or result in any `devDependencies`
      being added to the build plan - since these packages will have been
      "built" before distribution.
      However, `scripts.[pre|post]install` scripts ( generally `node-gyp`
      compilation ) does run for the `file` lifecycle.

      This option is effectively a shorthand for setting `lifecycle` defaults,
      but may also used by some fetchers and scrapers.

      See Also: lifecycle, fetchInfo
    '';
    type    = lib.libfloco.ltype;
    default = "file";
  };


# ---------------------------------------------------------------------------- #

  mkDepAttrsOption = lib.mkOption {
    description = lib.mdDoc ''
      Dependency declarations as attrs of `{ <NAME> = <DESCRIPTOR>; }`
      describing the required version ranges or location of a given dependency.
    '';
    type    = lib.libfloco.depAttrs;
    default = {};
    example = { lodash = "^4.17.21"; };
  };

  mkDepMetasOption = lib.mkOption {
    description = lib.mdDoc ''
      Dependency metadata/options declarations.
      Represented as attrs of `{ <NAME> = { <OPTION> = <BOOL>; }; }` indicating
      additional metadata about dependencies that cannot be inferred from
      their category.

      Conventionally this is used to indicate whether dependencies are optional,
      but additional `boolean` toggles may be used.
    '';
    type    = lib.libfloco.depAttrs;
    default = {};
    example = { lodash.optional = true; };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
