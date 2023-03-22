# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  # Maps keys to an integer index in an adjacency matrix.
  mkKeyIndex = p: let
    pdefs = if ! ( builtins.isAttrs p ) then p else
            p.pdefs or p.floco.pdefs or p.config.floco.pdefs or p;
    pdl = if builtins.isList pdefs then pdefs else
          lib.libfloco.pdefsToList pdefs;
    mkEnt = i: let
      pdef = builtins.elemAt pdl i;
    in {
      name  = pdef.key or ( pdef.ident + "/" + pdef.version );
      value = i;
    };
    index =
      builtins.listToAttrs ( builtins.genList mkEnt ( builtins.length pdl ) );
    lookup = index: let
      keys   = builtins.attrNames index;
      vals   = builtins.attrValues index;
    in x: let
      forIdx =
        if x < ( builtins.length keys ) then builtins.elemAt vals x else null;
      key = x.key or ( ( x.ident or x.name ) + "/" + ( x.version or x.pin ) );
    in if builtins.isString x then index.${x} or null else
       if builtins.isAttrs x then index.${key} or null else
       if builtins.isInt x then forIdx else throw (
         "libfloco.keyIndex:lookup: expected string or integer but second" +
         "argument is of type '${builtins.typeOf x}'."
       );
  in {
    inherit index;
    __functor = self: lookup self.index;
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    mkKeyIndex
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
