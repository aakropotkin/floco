# ============================================================================ #
#
# Implements `getChildReqs' and initializer for "naive" install strategy.
# This file is paired with the interfaces defined in `./types/graph.nix'.
#
# This strategy isn't really recommended for real usage, but serves as the
# simplest implementation of an install strategy.
#
# This strategy adds and dependencies that aren't satisfied by the parent scope
# as children.
# With that in mind it is somewhat similar to "hoisted", except that we do not
# create a giant top-level scope upfront.
#
# This strategy can be useful as a helper function in more advanced strategies.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

in {

  getChildReqsBasic = {
    ident
  , version
  , path
  , depInfo
  , peerInfo
  , isRoot
  , needs  ? if isRoot then depInfo else
             lib.libfloco.getRuntimeDeps { bundled = false; } depInfo
  , pscope
  , ...
  } @ node: let
    keep  = di: de: ( pscope.${di}.pin or null ) == de.pin;
    part  = lib.partitionAttrs keep needs;
    bund = lib.libfloco.getDepsWith ( de: de.bundled or false ) depInfo;
  in {
    requires = builtins.intersectAttrs ( part.right // peerInfo ) pscope;
    children = builtins.mapAttrs ( ident: { pin, ... }: {
      inherit pin;
      path = lib.nmjoin path ident;
    } ) ( bund // part.wrong );
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
