# ============================================================================ #
#
# Add or lookup `pdef' records from the `config.floco.pdefs' set.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  addFetcher = fetchers: { fetchInfo, ... } @ serialized: {
    _module.args.fetchers = lib.mkOverride 1002 fetchers;
    fetcher = let
      type =
        if builtins.isAttrs fetchInfo then fetchInfo.type or "path" else
        builtins.head ( builtins.match "([^+:]+)[+:].*" fetchInfo );
      fetcher = if type == "path" then "path" else "fetchTree_${type}";
    in lib.mkOverride 900 fetcher;
  } // serialized;


# ---------------------------------------------------------------------------- #

  /* Coerce a collection of `pdef` records to a set of config fields.
     If the argument is already an attrset this is a no-op.
     If the argument is a list its members will be treated as a module list to
     be merged.
     If the argument is a file it will be imported and processed as described
     above - JSON files will be converted to Nix expressions if the given path
     has a ".json" extension.

     This routine exists to simplify aggregation of `pdefs.nix' files.

     Returns a `config.floco.pdefs.<IDENTS.<VERSION>' attrset.

     Type: addPdefs :: (attrs|list|file) -> { config.floco.pdefs.*.*.* }

     Example:
       addPdefs [{ ident = "@floco/example"; version = "4.2.0"; ... }]
       => {
         config.floco.pdefs."@floco/example"."4.2.0" = {
           ident   = "@floco/example";
           version = "4.2.0";
           ...
         };
       }
  */
  addPdefs = pdefs: let
    fromFile = let
      raw = if lib.hasSuffix ".json" ( toString pdefs )
            then lib.importJSON pdefs
            else import pdefs;
    in { _file = toString pdefs; } // ( addPdefs raw );
    # Flattens multiple definitions naively and injects fetcher.
    # This is going to misbehave if you have multiple conflicting definitions
    # of a package so don't do that shit.
    fromList = let
      byIdent   = builtins.groupBy ( v: v.ident ) pdefs;
      byVersion = builtins.mapAttrs ( _: builtins.groupBy ( v: v.version ) )
                                    byIdent;
      merge = builtins.foldl' lib.recursiveUpdate {};
    in { config, ... }: {
      config.floco.pdefs = builtins.mapAttrs ( _: builtins.mapAttrs ( _: vs:
        addFetcher config.floco.fetchers ( merge vs )
      ) ) byVersion;
    };
    fromAttrs =
      if pdefs ? config.floco.pdefs then ( { config, ... }: {
        config = pdefs.config // {
          floco = pdefs.config.floco // {
            pdefs = builtins.mapAttrs ( _: builtins.mapAttrs ( _:
              addFetcher config.floco.fetchers
            ) ) pdefs.config.floco.pdefs;
          };
        };
      } ) else
      if pdefs ? floco  then ( { config, ... }: {
        config = pdefs // {
          floco = pdefs.floco // {
            pdefs = builtins.mapAttrs ( _: builtins.mapAttrs ( _:
              addFetcher config.floco.fetchers
            ) ) pdefs.floco.pdefs;
          };
        };
      } ) else
      if pdefs ? pdefs then ( { config, ... }: {
        config.floco = pdefs // {
          pdefs = builtins.mapAttrs ( _: builtins.mapAttrs ( _:
            addFetcher config.floco.fetchers
          ) ) pdefs.pdefs;
        };
      } )
      else throw "floco#lib.addPdefs: what the fuck did you try to pass bruce?";
    isFile = ( builtins.isPath pdefs ) || ( builtins.isString pdefs );
    module = if isFile then fromFile else
             if builtins.isAttrs pdefs then fromAttrs else fromList;
  in { imports = [module]; };


# ---------------------------------------------------------------------------- #

  getPdef' = pdefs: {
    key     ? null
  , ident   ? dirOf key
  , version ? baseNameOf key
  , ...
  } @ ka: pdefs.${ident}.${version} or null;

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
    key     ? null
  , ident   ? dirOf key
  , version ? baseNameOf key
  , ...
  } @ ka: let
    ident' = removeAttrs pdefs.${ident} [version];
  in if ( pdefs.${ident}.${version} or null ) == null then pdefs else
     if ident' != {} then pdefs // { ${ident} = ident'; } else
     removeAttrs pdefs [ident];

  killPdef = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: ka: let
    pdefs' = if builtins.isAttrs ka then killPdef' pdefs ka else
             killPdef' pdefs { key = ka; };
  in if pa ? config then { config.floco.pdefs = pdefs'; } else
     if pa ? floco  then { floco.pdefs = pdefs'; } else
     if pa ? pdefs  then { pdefs = pdefs'; } else
     pdefs';


# ---------------------------------------------------------------------------- #

  mapPdefs = fn: builtins.mapAttrs ( _: builtins.mapAttrs ( _: fn ) );

  filterPdefs = pred: pdefs: let
    vf = builtins.mapAttrs ( _: lib.filterAttrs ( _: pred ) ) pdefs;
  in lib.filterAttrs ( _: vs: vs != {} ) vf;

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

in {
  inherit
    getPdef
    killPdef

    addPdefs
    addFetcher

    mapPdefs
    filterPdefs
    pdefsToList
    pdefsFromList
    pdefsKeyed
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
