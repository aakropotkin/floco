# ============================================================================ #
#
# Add or lookup `pdef' records from the `config.floco.pdefs' set.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  getPdef' = pdefs: {
    key     ? ident + "/" + version
  , ident   ? dirOf key
  , version ? baseNameOf key
  , ...
  } @ ka: pdefs.${ident}.${version} or null;

  # This works but because this routine is hot we'll use a "more inlined" form.
  #getPdef = lib.libfloco.runNVFunction { modify = false; fn = getPdef'; };

  getPdef = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: ka:
    if builtins.isAttrs ka then getPdef' pdefs ka else
    getPdef' pdefs { key = ka; };



# ---------------------------------------------------------------------------- #

  killPdef' = pdefs: {
    key     ? ident + "/" + version
  , ident   ? dirOf key
  , version ? baseNameOf key
  , ...
  } @ ka: let
    ident' = removeAttrs pdefs.${ident} [version];
  in if ( pdefs.${ident}.${version} or null ) == null then pdefs else
     if ident' != {} then pdefs // { ${ident} = ident'; } else
     removeAttrs pdefs [ident];

  killPdef = lib.libfloco.runNVFunction { fn = killPdef'; };


# ---------------------------------------------------------------------------- #

  mapPdefs = fn: builtins.mapAttrs ( _: builtins.mapAttrs ( _: fn ) );

  filterPdefs = pred: pdefs: let
    vf = builtins.mapAttrs ( _: lib.filterAttrs ( _: pred ) ) pdefs;
  in lib.filterAttrs ( _: vs: vs != {} ) vf;


# ---------------------------------------------------------------------------- #

  detectPdefsStyle' = pdefs: let
    fa = pdefs.${builtins.head ( builtins.attrNames pdefs )};
  in if builtins.isList pdefs then "list" else
     if pdefs == {} then "ivAttrs" else
     if builtins.isList fa then "idGroups" else
     "ivAttrs";


# ---------------------------------------------------------------------------- #

  pdefsToList = pdefs:
    builtins.concatMap builtins.attrValues ( builtins.attrValues pdefs );

  pdefsFromList = pdefsL: let
    mkV  = p: { name = p.version; value = p; };
    proc = ident: versions: builtins.listToAttrs ( map mkV versions );
    g    = builtins.groupBy ( p: p.ident ) pdefsL;
  in builtins.mapAttrs proc g;

  pdefsKeyed = pdefs: let
    pdefsL = if builtins.isList pdefs then pdefs else pdefsToList pdefs;
  in builtins.listToAttrs ( map ( v: { name = v.key; value = v; } ) pdefsL );


# ---------------------------------------------------------------------------- #

  listPdefVersions = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: ident: builtins.attrNames ( pdefs.${ident} or {} );


# ---------------------------------------------------------------------------- #

in {
  inherit
    getPdef'
    getPdef
    killPdef

    mapPdefs
    filterPdefs
    pdefsToList
    pdefsFromList
    pdefsKeyed

    listPdefVersions
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
