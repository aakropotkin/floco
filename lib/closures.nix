# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  pdefClosure' = pdefs: keylike: let
    mkNode = builtins.intersectAttrs {
      key     = true; ident    = true; version  = true;
      depInfo = true; peerInfo = true;
    };
    get = ident: { pin, ... }: let
      full = lib.libfloco.getPdef { inherit pdefs; } {
        inherit ident; version = pin;
      };
    in mkNode full;
    operator = pdef: builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
  in builtins.genericClosure {
    startSet = operator ( mkNode ( lib.libfloco.getPdef pdefs keylike ) );
    inherit operator;
  };

  pdefClosure = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosure' pdefs keylike;


# ---------------------------------------------------------------------------- #

  # XXX: This routine is an incomplete draft.
  # Produce a "hoisted" `treeInfo' record from a closure.
  __treeInfoFromClosure = closure: rootKey: let
    noRoot      = builtins.filter ( pdef: pdef.key != rootKey ) closure;
    idGroups    = builtins.groupBy ( pdef: pdef.ident ) noRoot;
    topLevel    = builtins.mapAttrs ( _: builtins.head ) idGroups;
    isSingleton = id: builtins.length ( idGroups.${id} ) == 1;
    sparted     =
      builtins.partition isSingleton ( builtins.attrNames idGroups );
    markTopRequires = ident: pdef: let
      multis   = removeAttrs pdef.depInfo sparted.right;
      requires =
        lib.filterAttrs ( di: de: topLevel.${di}.version != de.pin ) multis;
    in pdef // { inherit requires; done = requires == {}; };
    top  = builtins.mapAttrs markTopRequires topLevel;
    rest = let
      proc = ident: pdefs: let
        mkEnt = pdef: {
          name  = pdef.version;
          value = markTopRequires ident pdef;
        };
      in builtins.listToAttrs ( map mkEnt ( builtins.tail pdefs ) );
    in builtins.mapAttrs proc ( removeAttrs idGroups sparted.right );
  in { inherit top rest; };


# ---------------------------------------------------------------------------- #

in {

  inherit
    pdefClosure
    __treeInfoFromClosure
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
