# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  mergePreferredOption = { compare }: loc: defs:
    builtins.head ( builtins.sort compare ( lib.getValues defs ) );


# ---------------------------------------------------------------------------- #

  mergeRelativePathOption = loc: defs: let
    toVal = { file, value, ... } @ def: let
      fp = if builtins.isPath file then file else /. + file;
    in if builtins.isPath value then value else
       if lib.isAbspath value then /. + value else
       fp + ( "/" + value );
    fixupDef = def: def // { value = toVal def; };
    fixed    = map fixupDef defs;
  in lib.mergeEqualOption loc fixed;


# ---------------------------------------------------------------------------- #

  moduleDropDefaults = submodule: value: let
    subs = submodule.getSubOptions [];
  in lib.filterAttrs ( f: v:
    ( ! ( subs.${f} ? default ) ) || ( v != subs.${f}.default )
  ) value;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
