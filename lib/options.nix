# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  mergePreferredOption = { compare }: loc: defs:
    builtins.head ( builtins.sort compare ( lib.getValues defs ) );

  moduleDropDefaults = submodule: value: let
    subs = submodule.getSubOptions [];
  in lib.filterAttrs ( f: v:
    ( ! ( subs.${f} ? default ) ) || ( v != subs.${f}.default )
  ) value;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
