# ============================================================================ #
#
# Indicates information about dependencies of a package/module.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  raw = let
    # Ignore `devDependencies*' for distributed tarballs.
    dev' = if config.ltype == "file" then {} else {
      devDependencies      = true;
      devDependenciesMeta  = true;
    };
    take = builtins.intersectAttrs ( dev' // {
      requires             = true;
      dependencies         = true;
      optionalDependencies = true;
      bundleDependencies   = true;
      bundledDependencies  = true;
    } );
    get = f:
      if ( config.metaFiles.${f} or {} ) == null then {} else
      take config.metaFiles.${f};
  in ( get "pjs" ) // ( get "plent" ) // ( get "ylent" ) // ( get "metaRaw" );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/depInfo/implementation.nix";

# ---------------------------------------------------------------------------- #

  config._module.args = {
    requires             = raw.requires or {};
    dependencies         = raw.dependencies or {};
    devDependencies      = raw.devDependencies or {};
    devDependenciesMeta  = raw.devDependenciesMeta or {};
    optionalDependencies = raw.optionalDependencies or {};
    bundledDependencies  = raw.bundledDependencies or [];
    bundleDependencies   = raw.bundleDependencies or false;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
