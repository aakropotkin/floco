# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  test = p: s: ( builtins.match p s ) != null;

  yank = p: s: let
    m = builtins.match p s;
  in if m == null then null else builtins.head m;

  yankN = n: p: s: let
    m = builtins.match p s;
  in if m == null then null else builtins.elemAt m n;


# ---------------------------------------------------------------------------- #

  size = x: let
    t = builtins.typeOf x;
  in if t == "string" then builtins.stringLength x else
     if t == "list" then builtins.length x else
     if t == "set" then builtins.length ( builtins.attrNames x ) else
     throw "floco#lib.libfloco.size: Cannot get size of type '${t}'";


# ---------------------------------------------------------------------------- #

in {

  inherit
    test
    yank
    yankN
    size
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
