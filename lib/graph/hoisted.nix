# ============================================================================ #
#
# Implements `getChildReqs' and initializer for "hoisted" install strategy.
# This file is paired with the interfaces defined in `./types/graph.nix'.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  # subScopeHoisted :: pdefslike -> keylike -> { scope, pcf }
  topScopeHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: rootKey: let
    closure = lib.libfloco.pdefClosureWith { outputStyle = "idGroup"; }
                                           { inherit pdefs; }
                                           rootKey;
    scope = builtins.mapAttrs ( ident: vs: {
      pin  = ( builtins.head vs ).version;
      path = if ( builtins.head vs ).key == rootKey then "" else
             "node_modules/" + ident;
      oneVersion = ( builtins.length vs ) < 2;
    } ) closure;
  in {
    inherit scope;
    pcf = lib.libfloco.mkPdefClosureCachedFunctor {
      addRoot = false;
      pdefs   = let
        proc = ident: vs: builtins.listToAttrs (
          map ( v: { name = v.version; value = v; } ) vs
        );
      in builtins.mapAttrs proc closure;
      rootPred  = { ckey = "dev"; __functor = self: de: true; };
      childPred = {
        ckey      = "hoistSub";
        __functor = self: de:
          de.runtime && ( ! ( scope.${de.ident}.oneVersion or false ) );
      };
      # XXX: You might not want to filter out the root if there's a cycle.
      cache.${rootKey}.dev = let
        toKeys = map ( v: v.key or ( v.ident + "/" + v.version ) );
        lst    = builtins.concatMap toKeys ( builtins.attrValues closure );
      in builtins.filter ( k: k != "rootKey" ) lst;
    };
  };


# ---------------------------------------------------------------------------- #

  # subScopeHoisted :: pdefslike -> closureFunctor -> node -> scope
  subScopeHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: pcf: {
    ident
  , version
  , key     ? ident + "/" + version
  , path
  , depInfo
  , peerInfo
  , pscope   ? node._module.args.pscope
  , ...
  } @ node: let
    clList   = pcf.payload.cache."${ident}/${version}".hoistSub;
    idGroups = builtins.groupBy dirOf clList;
    subscope = builtins.mapAttrs ( ident: vs: {
      pin        = baseNameOf ( builtins.head vs );
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
  } @ pa: { scope, pcf } @ top: {
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
      bund   = lib.libfloco.getDepsWith ( de: de.bundled or false ) depInfo;
      sub    = subScopeHoisted { inherit pdefs; } pcf node;
      scope' = let
        bund' = builtins.mapAttrs ( ident: { pin, ... }: {
          inherit pin;
          path = builtins.concatStringsSep "" [path "/node_modules/" ident];
          oneVersion = pscope.${ident}.oneVersion or false;
        } ) bund;
      in pscope // bund' // ( removeAttrs sub [ident] );
      keep = di: de:
        ( ! ( bund ? ${di} ) ) && ( ( pscope.${di}.pin or null ) == de.pin );
      part = lib.partitionAttrs keep scope';
    in {
      requires = builtins.intersectAttrs ( part.right // peerInfo ) pscope;
      children = builtins.intersectAttrs ( bund // part.wrong ) scope';
    };
    forRoot = { requires = {}; children = top.scope; };
  in if isRoot then forRoot else nonRoot;


# ---------------------------------------------------------------------------- #

in {

  inherit
    topScopeHoisted
    subScopeHoisted
    getChildReqsHoisted
  ;

  mkTreeInfoHoisted = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? config.floco.pdefs
  , ...
  } @ pa: keylike: let
    rootKey = if builtins.isString keylike then keylike else keylike.key or (
      keylike.ident + "/" + ( keylike.version or keylike.pin )
    );
    # Create a cached `pdefClosureFunctor', and initialize it forall `pdefs'.
    # This ensures that they will never be looked up redundantly later.
    # Note that we can know that every `pdef' would normally collect a closure
    # at least once, so this causes no loss of performance even for a flat tree.
    top = topScopeHoisted { inherit pdefs; } rootKey;
    pcf = let
      proc = p: key: if rootKey == key then p else p.__cacheChild p key;
    in builtins.foldl' proc top.pcf top.pcf.payload.cache.${rootKey}.dev;
  in lib.libfloco.mkTreeInfoWith {
    inherit (top.pcf.payload) pdefs;
    getChildReqs = lib.libfloco.getChildReqsHoisted {
      inherit (top.pcf.payload) pdefs;
    } ( top // { inherit pcf; } );
  } keylike;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
