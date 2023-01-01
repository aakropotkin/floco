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
      if ( config.metaFiles.${f} or {} ) == null then {} else
      take config.metaFiles.${f};
  in ( get "pjs" ) // ( get "plent" ) // ( get "metaRaw" );

# ---------------------------------------------------------------------------- #

in {

  config = {
    peerInfo = builtins.mapAttrs ( ident: _:
      import ./single.implementation.nix ( { inherit lib ident; } // raw )
    ) ( ( raw.peerDependencies or {} ) // ( raw.peerDependenciesMeta or {} ) );
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
