# ============================================================================ #
#
# Information concerning `peerDependencies' or "propagated dependencies".
#
# ---------------------------------------------------------------------------- #

{ lib
, ident
, peerDependencies
, peerDependenciesMeta
, ...
}: let

# ---------------------------------------------------------------------------- #

in {

  config = {
    descriptor = lib.mkDefault ( peerDependencies.${ident} or "*" );
    optional   =
      lib.mkDefault ( peerDependenciesMeta.${ident}.optional or false );
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
