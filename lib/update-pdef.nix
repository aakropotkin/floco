# ============================================================================ #
#
# Utilities for updating `pdef' records, and collections of `pdef' records.
#
# Largely this aims to cherry pick fields that are "known to be good",
# particularly info scraped from registry manifests/tarballs, vs. info that may
# be dirty such as local project manifests, `depInfo.*.pin' fields, `treeInfo',
# and similar info.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #
#
# For Reference:
#
#  registryPreserves = {
#    key        = true;
#    ident      = true;
#    version    = true;
#    ltype      = true;  # *
#    fetchInfo  = true;  # *
#    sourceInfo = true;  # *
#    binInfo    = true;  # *
#    depInfo    = {
#      descriptor = true;
#      pin        = false;  # ***
#      optional   = true;
#      bundled    = true;
#      runtime    = true;
#      dev        = true;
#    };
#    peerInfo     = true;  # only okay because it doesn't contain pins
#    sysInfo      = true;
#    fsInfo       = true;
#    lifecycle    = true;
#    treeInfo     = false;  # ***
#    metaFiles    = false;  # ***
#    deserialized = false;  # ***
#    _export     = false;  # *** Contains `treeInfo' and `depInfo'
#  };
#

# ---------------------------------------------------------------------------- #

  setLowPriorityForUpdateRegistry = pdef: pdef // {
    depInfo = let
      proc = ident: de: de // { pin = lib.mkOptionDefault ( de.pin or null ); };
    in builtins.mapAttrs proc ( pdef.depInfo or {} );
    treeInfo     = lib.mkOptionDefault ( pdef.treeInfo or null );
    metaFiles    = lib.mkOptionDefault ( pdef.metaFiles or {} );
    deserialized = lib.mkOptionDefault ( pdef.deserialized or false );
    _export      =
      builtins.mapAttrs ( _: lib.mkOptionDefault ) ( pdef._export or {} );
  };


# ---------------------------------------------------------------------------- #

  setLowPriorityForUpdateSrc = pdef:
    ( builtins.mapAttrs ( _: lib.mkOptionDefault ) pdef ) // {
      inherit (pdef) ident version key;
      depInfo = let
        proc = ident: de:
          de // { pin = lib.mkOptionDefault ( de.pin or null ); };
      in builtins.mapAttrs proc ( pdef.depInfo or {} );
      treeInfo     = lib.mkOptionDefault ( pdef.treeInfo or null );
      metaFiles    = lib.mkOptionDefault ( pdef.metaFiles or {} );
      deserialized = lib.mkOptionDefault ( pdef.deserialized or false );
      _export      =
        builtins.mapAttrs ( _: lib.mkOptionDefault ) ( pdef._export or {} );
    };


# ---------------------------------------------------------------------------- #

  setLowPriorityForUpdate = pdef:
    if pdef.ltype == "file" then setLowPriorityForUpdateRegistry pdef else
    setLowPriorityForUpdateSrc pdef;


# ---------------------------------------------------------------------------- #

in {
  inherit
    setLowPriorityForUpdateRegistry
    setLowPriorityForUpdateSrc
    setLowPriorityForUpdate
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
