# ============================================================================ #
#
# Indicates information about dependencies of a package/module.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: let

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
  in ( get "pjs" ) // ( get "plent" ) // ( get "ylent" ) // ( get "metaRaw" );

  idents = let
    # `requires' may be a boolen if it appears at the top level, so we want
    # to type check these fields first.
    attrs  = builtins.filter builtins.isAttrs ( builtins.attrValues raw );
    merged = builtins.foldl' ( a: b: a // b ) {} attrs;
  in ( builtins.attrNames merged ) ++ ( raw.bundledDependencies or [] );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/depInfo/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.depInfo = let
    base = acc: ident: acc // {
      ${ident} = import ./single.implementation.nix ( raw // {
        inherit lib ident;
      } );
    };
    dft = let
      subOpts =
        removeAttrs ( options.depInfo.type.getSubOptions [] ) ["_module"];
    in builtins.mapAttrs ( _: o:
      lib.mkOverride 900 o.default
    ) ( lib.filterAttrs ( _: o: o ? default ) subOpts );
    deserial = _: _: dft;
    proc = if config.deserialized then deserial else base;
  in builtins.foldl' proc {} idents;

  config._export = let
    depInfo = let
      iface = import ./single.interface.nix { inherit lib; };
      proc  = ident: dent: let
        nonDefault = f: v: v != ( iface.options.${f}.default or false );
      in builtins.mapAttrs ( f: v: lib.mkIf ( nonDefault f v ) v ) dent;
    in builtins.mapAttrs proc config.depInfo;
  in lib.mkIf ( config.depInfo != {} ) { inherit depInfo; };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #