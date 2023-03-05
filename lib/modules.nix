# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  moduleHandleJSONPath = x: let
    cpath  = lib.libfloco.coercePath x;
    isJSON = lib.hasSuffix ".json" cpath;
  in if ! ( ( lib.libfloco.isCoercibleToPath x ) && isJSON ) then x else
     lib.modules.importJSON cpath;


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  inherit
    moduleHandleJSONPath
  ;


# ---------------------------------------------------------------------------- #

  moduleDropDefaults = submodule: value: let
    subs = submodule.getSubOptions [];
  in lib.filterAttrs ( f: v:
    ( ! ( subs.${f} ? default ) ) || ( v != subs.${f}.default )
  ) value;


# ---------------------------------------------------------------------------- #

  # Pre-process a list of modules ( conventionally used in `imports' lists, or
  # `lib.evalModules' invocations ) to automatically import JSON files, and
  # ( optionally ) override the treatment of `default.nix' files.
  #
  # Additionally directories may be searched for the files
  # `floco-cfg.{nix,json}' or `pdefs.{nix,json}' and `foverrides.{nix,json}'.
  # The option `preferFlocoCfgs' will cause directories the use these files
  # instead of `default.nix' files if both are present.
  #
  # The option `ignoreDefaultNix' will prevent `default.nix' files from being
  # considered for use as modules entirely, which may be useful if you are using
  # that file for CLI targets.
  # This makes it an error to specify a directory which lacks floco
  # config files.
  #
  # Notes:
  #   - `*.nix' files are always preferred over `*.json' files of the same name.
  #   - the presence of `floco-cfg.{nix,json}' causes
  #     `{pdefs,foverrides}.{nix,json}' files to be ignored.
  #     + It is assumed that these files are already included in
  #       `floco-cfg.{nix,json}', so including them again would be redundant.
  #   - `preferFlocoCfgs = true; ignoreDefaultNix = false;' will cause
  #     `default.nix' files to be used only as a fallback.
  #     + You'll throw an error if `default.nix' isn't a valid module file.
  #   - `ignoreDefaultNix = true;' makes `preferFlocoCfgs' irrelevant.
  processImport' = {
    ignoreDefaultNix ? false
  , preferFlocoCfgs  ? false
  }: x: let
    isPathlike = lib.libfloco.isCoercibleToPath x;
    cpath      = lib.libfloco.coercePath x;
    hasDftNix  = builtins.pathExists ( cpath + "/default.nix" );
    flocoCfgs  = lib.libfloco.flocoConfigsFromDir cpath;
    subs       =
      if preferFlocoCfgs && ( flocoCfgs != [] ) then flocoCfgs else
      if ( ! ignoreDefaultNix ) && hasDftNix then x else flocoCfgs;
  in if ! isPathlike then x else
     if ! ( lib.libfloco.isDir cpath ) then moduleHandleJSONPath cpath else
     if 1 == ( builtins.length subs ) then builtins.head subs else
     { _file = cpath; imports = subs; };

  processImports' = {
    ignoreDefaultNix ? false
  , preferFlocoCfgs  ? false
  } @ opts: x:
    map ( lib.libfloco.processImport' opts ) ( lib.toList x );


  processImportFloco  =
    lib.libfloco.processImport'  { preferFlocoCfgs = true; };
  processImportsFloco =
    lib.libfloco.processImports' { preferFlocoCfgs = true; };
  processImport  = lib.libfloco.processImport'  { ignoreDefaultNix = false; };
  processImports = lib.libfloco.processImports' { ignoreDefaultNix = false; };


# ---------------------------------------------------------------------------- #

  getModuleBaseName = options: let
    inherit (options._module.specialArgs) loc;
    len = builtins.length loc;
  in builtins.elemAt loc ( len - 3 );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
