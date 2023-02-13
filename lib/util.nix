# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  libLoc    = "floco#lib.libfloco";
  throwFrom = fn: msg: throw "${libLoc}.${fn}: ${msg}";

# ---------------------------------------------------------------------------- #

  depPinsToKeys = {
    depInfo ? {}
  , key     ? ident + "/" + version
  , ident
  , version
  , ...
  } @ pdef: let
    deToKey = dIdent: { pin ? throwFrom "depPinsToKeys" "pin not found", ... }:
      "${dIdent}/${pin}";
  in builtins.mapAttrs deToKey depInfo;


# ---------------------------------------------------------------------------- #

  depPinsToDOT = {
    depInfo ? {}
  , key     ? ident + "/" + version
  , ident
  , version
  , ...
  } @ pdef: let
    toDOT = _: depKey: "  " + ''"${depKey}" -> "${key}";'';
  in builtins.attrValues ( builtins.mapAttrs toDOT ( depPinsToKeys pdef ) );


  pdefsToDOT = {
    graphName ? "flocoPackages"
  , pdefs     ? {}
  }: let
    pdefsL = if builtins.isList pdefs then pdefs else
             lib.collect ( v: v ? _export ) pdefs;
    dot    = builtins.concatMap depPinsToDOT pdefsL;
    header = ''
      digraph ${graphName} {
    '';
  in header + ( builtins.concatStringsSep "\n" dot ) + "\n}";


# ---------------------------------------------------------------------------- #

in {

  inherit
    depPinsToKeys
    depPinsToDOT
    pdefsToDOT
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
