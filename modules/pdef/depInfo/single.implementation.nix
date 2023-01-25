# ============================================================================ #
#
# Implementation for a single `depInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib
, ident
, requires             ? {}
, dependencies         ? requires
, devDependencies      ? {}
, devDependenciesMeta  ? {}
, optionalDependencies ? {}
, bundleDependencies   ? false
, bundledDependencies  ? []
, ...
}: let

# ---------------------------------------------------------------------------- #

  runtimeDeps = requires // optionalDependencies // dependencies;

# ---------------------------------------------------------------------------- #

in builtins.mapAttrs ( _: lib.mkDefault ) {

# ---------------------------------------------------------------------------- #

  descriptor = runtimeDeps.${ident} or devDependencies.${ident} or "*";
  runtime    = ( runtimeDeps ? ${ident} ) ||
               ( builtins.elem ident bundledDependencies );
  dev = ( runtimeDeps ? ${ident} ) ||
        ( devDependencies ? ${ident} ) ||
        ( devDependenciesMeta ? ${ident} );
  optional = ( optionalDependencies ? ${ident} ) ||
             ( devDependenciesMeta.${ident}.optional or false );
  bundled = ( bundleDependencies && ( runtimeDeps ? ${ident} ) ) ||
            ( builtins.elem ident bundledDependencies );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
