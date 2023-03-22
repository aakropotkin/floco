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
  mkKeyIndex = pdefs: let
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
  in {
    inherit index;
    lookup = index: x: let
      keys   = builtins.attrNames index;
      vals   = builtins.attrValues index;
      forIdx =
        if x < ( builtins.length keys ) then builtins.elemAt vals x else null;
    in if builtins.isString x then index.${x} or null else
       if builtins.isInt x then forIdx else throw (
         "libfloco.keyIndex:lookup: expected string or integer but second" +
         "argument is of type '${builtins.typeOf x}'."
       );
    __functor = self: x: self.lookup self.index x;
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
