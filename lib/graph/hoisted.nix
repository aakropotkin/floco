# ============================================================================ #
#
# Implements `getChildReqs' and initializer for "hoisted" install strategy.
# This file is paired with the interfaces defined in `./types/graph.nix'.
#
# NOTE: This implementation does not precisely reproduce the "hoisted" trees
# created by `npm` or `yarn` ( which also differ from each other ), because it
# does not "hoist subtrees".
# This means that only the "top-level" `node_modules/' directory is hoisted,
# while all subtrees use the "naive" strategy, adding dependencies as children
# in the subdir of packages which request them.
#
# TODO: Hoist subtrees to improve deduplication.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  topChildrenHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: keylike: let
    lf      = lib.libfloco;
    closure =
      lf.pdefClosureWith ( _: true ) ( de: de.runtime ) { inherit pdefs; }
                         keylike;
    rootKey = if builtins.isString keylike then keylike else keylike.key or (
      keylike.ident + "/" + ( keylike.version or keylike.pin )
    );
    noRoot   = builtins.filter ( pdef: pdef.key != rootKey ) closure;
    idGroups = builtins.groupBy ( pdef: pdef.ident ) noRoot;
  in builtins.mapAttrs ( _: vs: ( builtins.head vs ).version ) idGroups;


# ---------------------------------------------------------------------------- #

  getChildReqsHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: {
    ident
  , version
  , path
  , depInfo
  , peerInfo
  , isRoot
  , needs  ? if isRoot then depInfo else lib.libfloco.getRuntimeDeps {} depInfo
  , pscope
  , ...
  } @ node: let
    keep    = di: de: ( pscope.${di}.pin or null ) == de.pin;
    part    = lib.partitionAttrs keep needs;
    bund    = lib.libfloco.getDepsWith ( de: de.bundled or false ) depInfo;
    nonRoot = {
      requires = builtins.intersectAttrs ( part.right // peerInfo ) pscope;
      children = builtins.mapAttrs ( _: d: d.pin ) ( bund // part.wrong );
    };
    forRoot = {
      requires = {};
      children =
        topChildrenHoisted { inherit pdefs; } { inherit ident version; };
    };
  in if isRoot then forRoot else nonRoot;


# ---------------------------------------------------------------------------- #

in {

  inherit
    topChildrenHoisted
    getChildReqsHoisted
  ;

  mkTreeInfoHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: lib.libfloco.mkTreeInfoWith {
    inherit pdefs;
    getChildReqs = lib.libfloco.getChildReqsHoisted { inherit pdefs; };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
