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

  setLowPriorityForUpdateRegistry = pdef: ( removeAttrs pdef ["_module"] ) // {
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

  setLowPriorityForUpdateSrc = pdef: let
    nmod = removeAttrs pdef ["_module"];
  in ( builtins.mapAttrs ( _: lib.mkOptionDefault ) nmod ) // {
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

  prepConfigForUpdate' = {
    flocoTopModule  ? import ../modules/top
  , settingsModule  ? {}  # Should provide `config.floco.settings'
  , configModules
  }: let
    mod = lib.evalModules {
      modules = [flocoTopModule settingsModule] ++ configModules;
    };
  in {
    config.floco.pdefs =
      lib.mapPdefs setLowPriorityForUpdate mod.config.floco.pdefs;
  };

  # XXX: If you're updating any local projects you must pass `settingsModule'.
  prepConfigForUpdate = x: let
    args =
      if lib.isFunction  x then { configModules = [x]; } else
      if builtins.isList x then { configModules = x; } else
      if x ? configModules then x else
      { configModules = [x]; };
  in prepConfigForUpdate' args;


# ---------------------------------------------------------------------------- #

in {
  inherit
    setLowPriorityForUpdateRegistry
    setLowPriorityForUpdateSrc
    setLowPriorityForUpdate
    prepConfigForUpdate'
    prepConfigForUpdate
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
