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

  getPdef = {
    config ? null
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  }: {
    key
  , ident   ? dirOf key
  , version ? baseNameOf key
  }: pdefs.${ident}.${version};


# ---------------------------------------------------------------------------- #

in {
  inherit
    getPdef
    addPdefs
    addFetcher
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
