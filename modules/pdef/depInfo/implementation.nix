# ============================================================================ #
#
# Indicates information about dependencies of a package/module.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  raw = let
    dev' = if ! config.lifecycle.build then {} else {
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
  in ( get "pjs" ) // ( get "plent" ) // ( get "metaRaw" );

  idents = let
    merged = builtins.foldl' ( a: b: a // b ) {} ( builtins.attrValues raw );
  in builtins.attrNames merged;


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  config.depInfo = let
    proc = acc: ident: acc // {
      ${ident} = import ./single.implementation.nix ( raw // {
        inherit lib ident;
      } );
    };
  in builtins.foldl' proc {} idents;

  config._export.depInfo = let
    iface = import ./single.interface.nix { inherit lib; };
    proc  = ident: dent: let
      nonDefault = f: v: v != ( iface.options.${f}.default or false );
    in builtins.mapAttrs ( f: v: lib.mkIf ( nonDefault f v ) v ) dent;
  in builtins.mapAttrs proc config.depInfo;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
