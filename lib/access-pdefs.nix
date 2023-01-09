# ============================================================================ #
#
# Add or lookup `pdef' records from the `config.floco.pdefs' set.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

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
    in addPdefs raw;
    fromList.floco.pdefs = ( lib.evalModules {
      modules = [../modules/pdefs] ++ ( map ( v: {
        config.pdefs.${v.ident}.${v.version} = v;
      } ) pdefs );
    } ).config.pdefs;
    fromAttrs =
      if pdefs ? config then pdefs.config else
      if pdefs ? floco then pdefs else
      if pdefs ? pdefs then { floco = { inherit pdefs; }; } else
      throw "floco#lib.addPdefs: what the fuck did you try to pass bruce?";
    isFile = ( builtins.isPath pdefs ) || ( builtins.isString pdefs );
  in if isFile then fromFile else {
    config = if builtins.isAttrs pdefs then fromAttrs else fromList;
  };


# ---------------------------------------------------------------------------- #

  getPdef = {
    config        ? null
  , floco ? config.floco
  , pdefs         ? floco.pdefs
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
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
