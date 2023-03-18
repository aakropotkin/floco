# ============================================================================ #
#
# Implements `getChildReqs' and initializer for "hoisted" install strategy.
# This file is paired with the interfaces defined in `./types/graph.nix'.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  topScopeHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: keylike: let
    lf      = lib.libfloco;
    closure = lf.pdefClosure { inherit pdefs; } keylike;
    rootKey = if builtins.isString keylike then keylike else keylike.key or (
      keylike.ident + "/" + ( keylike.version or keylike.pin )
    );
    noRoot   = builtins.filter ( pdef: pdef.key != rootKey ) closure;
    idGroups = builtins.groupBy ( pdef: pdef.ident ) noRoot;
  in builtins.mapAttrs ( ident: vs: {
    pin        = ( builtins.head vs ).version;
    path       = "node_modules/" + ident;
    oneVersion = ( builtins.length vs ) < 2;
  } ) idGroups;


# ---------------------------------------------------------------------------- #

  subScopeHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: {
    ident
  , version
  , key     ? ident + "/" + version
  , path
  , depInfo
  , peerInfo
  , pscope   ? node._module.args.pscope
  , ...
  } @ node: let
    lf   = lib.libfloco;
    pred = de: de.runtime && ( ! ( pscope.${de.ident}.oneVersion or false ) );
    closure = lf.pdefClosureWith {
      rootPred = pred; childPred = pred;
    } { inherit pdefs; } { inherit ident version; };
    noRoot   = builtins.filter ( pdef: pdef.key != key ) closure;
    idGroups = builtins.groupBy ( pdef: pdef.ident ) noRoot;
    subscope = builtins.mapAttrs ( ident: vs: {
      pin        = ( builtins.head vs ).version;
      path       = builtins.concatStringsSep "" [path "/node_modules/" ident];
      oneVersion = ( builtins.length vs ) < 2;
    } ) idGroups;
  in builtins.addErrorContext "while collecting `subscopeHoisted' of `${key}'"
                              subscope;


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
  , pscope
  , ...
  } @ node: let
    nonRoot = let
      bund  = lib.libfloco.getDepsWith ( de: de.bundled or false ) depInfo;
      sub   = subScopeHoisted { inherit pdefs; } node;
      scope = let
        bund' = builtins.mapAttrs ( ident: { pin, ... }: {
          inherit pin;
          path = builtins.concatStringsSep "" [path "/node_modules/" ident];
          oneVersion = pscope.${ident}.oneVersion or false;
        } ) bund;
      in pscope // bund' // sub;
      keep = di: de:
        ( ! ( bund ? ${di} ) ) && ( ( pscope.${di}.pin or null ) == de.pin );
      part = lib.partitionAttrs keep scope;
    in {
      requires = builtins.intersectAttrs ( part.right // peerInfo ) pscope;
      children = builtins.intersectAttrs ( bund // part.wrong ) scope;
    };
    forRoot = {
      requires = {};
      children = topScopeHoisted { inherit pdefs; } { inherit ident version; };
    };
  in if isRoot then forRoot else nonRoot;


# ---------------------------------------------------------------------------- #

in {

  inherit
    topScopeHoisted
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
