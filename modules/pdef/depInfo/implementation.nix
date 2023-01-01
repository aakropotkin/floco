# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  raw = let
    take = builtins.intersectAttrs {
      requires             = true;
      dependencies         = true;
      devDependencies      = true;
      devDependenciesMeta  = true;
      optionalDependencies = true;
      bundleDependencies   = true;
      bundledDependencies  = true;
    };
    get = f:
      if ( config.metaFiles.${f} or {} ) == null then {} else
      take config.metaFiles.${f};
  in ( get "pjs" ) // ( get "plent" ) // ( get "metaRaw" );

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #
#
# requires             = { id -> desc }
# dependencies         = { id -> desc }
# devDependencies      = { id -> desc }
# devDependenciesMeta  = { id -> { optional ::= bool } }
# optionalDependencies = { id -> desc }
# bundleDependencies   = [id]
# bundledDependencies  = bool
#
# ---------------------------------------------------------------------------- #
#
# {
#   descriptor
#   pin
#   optional
#   bundled
#   runtime
#   dev
#   test
#   lint
# }
#
#
# ---------------------------------------------------------------------------- #

  config.depInfo = lib.mkDefault ( builtins.foldl' lib.recursiveUpdate {} [

    ( builtins.mapAttrs ( _: descriptor: {
        inherit descriptor;
        runtime = true;
        dev     = true;
        test    = true;
        lint    = true;
      } ) ( ( raw.dependencies or {} ) // ( raw.requires or {} ) ) )

    ( builtins.mapAttrs ( k: descriptor:
      ( raw.devDependenciesMeta.${k} or {} ) // {
        inherit descriptor;
        runtime = false;
        dev     = true;
        test    = true;
        lint    = true;
      } ) ( raw.devDependencies or {} ) )

    ( builtins.mapAttrs ( _: descriptor: {
        inherit descriptor;
        optional = true;
        runtime  = true;
        dev      = true;
        test     = true;
        lint     = true;
      } ) ( raw.optionalDependencies or {} ) )

    ( builtins.mapAttrs ( _: descriptor: {
        inherit descriptor;
        bundled = true;
      } ) ( raw.bundledDependencies or {} ) )

    ( if ! ( raw.bundleDependencies or false ) then {} else
        builtins.mapAttrs ( _: descriptor: {
          inherit descriptor;
          bundled = true;
        } ) ( raw.dependencies or {} ) )

  ] );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
