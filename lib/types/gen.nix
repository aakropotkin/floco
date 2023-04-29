# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  applyList = fn: lst: let
    lookup = x: if ! ( builtins.isString x ) then x else
                lib.types.${x} or lib.libfloco.${x} or x;
  in builtins.foldl' ( f: x: f ( lookup x ) ) ( lookup fn ) ( lib.toList lst );


# ---------------------------------------------------------------------------- #

  # Deserialize a typedef.
  genType' = def: let
    key       = builtins.head ( builtins.attrNames def );
    fromAttrs = applyList key def.${key};
  in if builtins.isAttrs def then fromAttrs else
     if builtins.isString def then lib.types.${def} or lib.libfloco.${def} else
     def;

  genType = def:
    if ! ( def ? type ) then genType' def else
    ( genType' def.type ) // ( removeAttrs def ["type"] );


# ---------------------------------------------------------------------------- #




# ---------------------------------------------------------------------------- #

in {

  inherit genType;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
