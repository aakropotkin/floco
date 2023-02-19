# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

  libLoc    = "floco#lib.libfloco";
  throwFrom = fn: msg: throw ( libLoc + "." + fn + ": " + msg );

# ---------------------------------------------------------------------------- #

  specOverride = let
    final = nt.submodule {
      freeformType = nt.attrsOf final;
      options."."  = lib.mkOption { type = nt.str; default = "*"; };
    };
    coerce = x:
      if builtins.isString x then { "." = x; } else
      if builtins.isAttrs x then builtins.mapAttrs norm x else
      throwFrom "specOverride" (
        "expected type string or attrs, but got type " +
        ( builtins.typeOf x )
      );
    norm = k: v:
      if ( k == "." ) && ( ! ( builtins.isString v ) ) then
        throwFrom "specOverride" "override '.' must be a string"
      else if ( k == "." ) then v else coerce v;
  in final // {
    name        = "specOverride";
    description = "A collection of overrides associated with an identifier";
    emptyValue  = {};
    check       = x: ( final.check x ) || ( final.check ( coerce x ) );
    merge       = loc: defs: let
      coerced = map ( def: def // { value = coerce def.value; } ) defs;
    in final.merge loc coerced;
  };


# ---------------------------------------------------------------------------- #

  # FIXME: You need to do this with plain recursiion.
  # You don't need `curr`.
  # Instead you should just iterate over the list of, and build up `rules` so
  # that you traverse the tree correctly.
  # Right now you're destroying substrees.

  #specOverrideSetGetRuleset = root: path: let
  #  proc = { curr, rules }: next: let
  #    newPath  = curr ++ [next];
  #    base     = lib.attrByPath newPath { "." = "*"; } rules;
  #    override = rules // base;
  #  in {
  #    curr  = newPath;
  #    rules = { ${next} = override; } // base;
  #  };
  #  inherit (builtins.foldl' proc { curr = []; rules = root; } path) rules;
  #in removeAttrs rules ["."];


# ---------------------------------------------------------------------------- #

in {

  inherit specOverride;
  specOverrideSet =
    nt.addCheck ( nt.attrsOf specOverride ) ( x: ! ( x ? "." ) );

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
