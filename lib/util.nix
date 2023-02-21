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

  depPinsToKeys = x: let
    depInfo = x.depInfo or x;
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

  show       = s: builtins.trace ( "\n" + s + "\n" ) null;
  showPretty = x: show ( lib.generators.toPretty {} x );

  showPrettyCurried = x:
    if ! ( builtins.isFunction x ) then showPretty x else
    y: showPrettyCurried ( x y );


# ---------------------------------------------------------------------------- #

in {

  inherit
    depPinsToKeys
    depPinsToDOT
    pdefsToDOT

    show showPretty showPrettyCurried
  ;

  spp = showPrettyCurried;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
