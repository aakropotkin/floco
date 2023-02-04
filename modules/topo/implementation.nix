# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, pkgs, config, ... }: let

  pdl = lib.collect ( v: v ? _export ) config.pdefs;

  pdefToTopoEnt = pdef: { inherit (pdef) depInfo ident version key; };

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/topo/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.topo.toposortNoPins = pdefsL:
    lib.toposort ( a: b: b.depInfo ? ${a.ident} ) ( map pdefToTopoEnt pdefsL );

  config.topo.toposortPins = pdefsL: lib.toposort ( a: b:
    ( b.depInfo ? ${a.ident} ) && ( b.depInfo.${a.ident}.pin == a.version )
  ) ( map pdefToTopoEnt pdefsL );


# ---------------------------------------------------------------------------- #

  config.topo.pdefsHaveSingleVersion = let
    pred = ident:
      ( builtins.length ( builtins.attrNames config.pdefs.${ident} ) ) <= 1;
  in builtins.all pred ( builtins.attrNames config.pdefs );

  config.topo.pdefsHavePins = let
    pred = pdef:
      builtins.all ( d: ( d.pin or null ) != null )
                   ( builtins.attrValues pdef.depInfo );
  in builtins.all pred pdl;


# ---------------------------------------------------------------------------- #

  config.topo.toposortedAll = let
    msg = "floco: topo: It is an error to call this with incomplete metadata.";
    fn  =
      if config.topo.pdefsHaveSingleVersion then config.topo.toposortNoPins else
      if config.topo.pdefsHavePins then config.topo.toposortPins else
      throw msg;
  in fn pdl;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
