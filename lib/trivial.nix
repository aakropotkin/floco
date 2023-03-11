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

  partitionAttrs = pred: attrs: let
    npred = name: pred name attrs.${name};
    part  = builtins.partition npred ( builtins.attrNames attrs );
  in {
    right = removeAttrs attrs part.wrong;
    wrong = removeAttrs attrs part.right;
  };


# ---------------------------------------------------------------------------- #

  # Remove fields from `attrs` that are not in `fields`.
  # Fields may be an attrset, a string ( single field ), or list of field names.
  keepAttrs = attrs: fields: let
    mkAttr = name: { inherit name; value = null; };
    keeps  = if builtins.isAttrs  fields then fields else
             if builtins.isString fields then { ${fields} = null; } else
             assert builtins.isList fields;
             builtins.listToAttrs ( map mkAttr fields );
  in builtins.intersectAttrs keeps attrs;


# ---------------------------------------------------------------------------- #

in {

  inherit
    test
    yank
    yankN
    size
    partitionAttrs
    keepAttrs
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
