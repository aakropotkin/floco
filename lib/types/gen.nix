# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  applyList = let
    lookup = x: if ! ( builtins.isString x ) then x else
                lib.types.${x} or lib.libfloco.${x} or x;
  in fn: lst:
    builtins.foldl' ( f: x: f ( lookup x ) ) ( lookup fn ) ( lib.toList lst );


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
    ( genType' def.type ) // ( removeAttrs def ["type" "merge" "example"] );


# ---------------------------------------------------------------------------- #

  genOption = {
    name        ? "???"
  , description ? name
  , type
  , example     ? null
  , merge       ? null
  } @ def: let
    m' = if ! ( def ? merge ) then {} else {
      merge = if ! ( builtins.isString merge ) then merge else
              lib.${merge} or lib.options.${merge} or lib.libfloco.${merge};
    };
    t  = lib.libfloco.genType def;
    e' = if ! ( def ? example ) then {} else {
      example = assert t.check example; example;
    };
    args = ( removeAttrs def ["name" "merge"] ) // {
      type        = t;
      description = if builtins.isString description then lib.mdDoc description
                                                     else description;
    } // m' // e';
  in lib.mkOption args;


# ---------------------------------------------------------------------------- #

in {

  inherit genType genOption;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
