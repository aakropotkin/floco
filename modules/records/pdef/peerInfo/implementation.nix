# ============================================================================ #
#
# Information concerning `peerDependencies' or "propagated dependencies".
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  raw = let
    take = builtins.intersectAttrs {
      peerDependencies     = true;
      peerDependenciesMeta = true;
    };
    get = f:
      if ( config.metaFiles.${f} or null ) == null then {} else
      take config.metaFiles.${f};
  in ( get "pjs" ) // ( get "plent" ) // ( get "metaRaw" );

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/peerInfo/implementation.nix";

# ---------------------------------------------------------------------------- #


  config = {
    peerInfo = builtins.mapAttrs ( ident: _:
      import ./single.implementation.nix ( { inherit lib ident; } // raw )
    ) ( ( raw.peerDependencies or {} ) // ( raw.peerDependenciesMeta or {} ) );
    _export = lib.mkIf ( config.peerInfo != {} ) {
      peerInfo = let
        iface = import ./single.interface.nix { inherit lib; };
      in builtins.mapAttrs ( _: builtins.mapAttrs ( f: v:
        if f == "descriptor" then v else
        lib.mkIf ( v != iface.options.${f}.default ) v
      ) ) config.peerInfo;
    };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
