# ============================================================================ #
#
# Coerce a collection of `pdef' records to a set of config fields.
#
# If the argument is already an attrset this is a no-op.
# If the argument is a list its members will be treated as a module list to
# be merged.
# If the argument is a file it will be imported and processed as described
# above - JSON files will be converted to Nix expressions if the given path
# has a ".json" extension.
#
# This routine exists to simplify aggregation of `pdefs.nix' files.
#
# Returns a `config.flocoPackages.pdefs.<IDENTS.<VERSION>' attrset.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  /* Coerce a collection of `pdef` records to a set of config fields.

     Type: addPdefs :: (attrs|list|file) -> { config.flocoPackages.pdefs.*.*.* }

     Example:
       addPdefs [{ ident = "@floco/example"; version = "4.2.0"; ... }]
       => {
         config.flocoPackages.pdefs."@floco/example"."4.2.0" = {
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
    fromList.flocoPackages.pdefs = ( lib.evalModules {
      modules = [
        {
          config._module.args.pkgs = {
            dummy = throw
              "Maintainers' TODO: separate top level `pdefs' to avoid this.";
          };
        }
        ../modules/packages
      ] ++ ( map ( v: {
        flocoPackages.pdefs.${v.ident}.${v.version} = v;
      } ) pdefs );
    } ).config.flocoPackages.pdefs;
    fromAttrs =
      if pdefs ? flocoPackages then pdefs else
      if pdefs ? pdefs then { flocoPackages = { inherit pdefs; }; } else
      throw "addPdefs: what the fuck did you try to pass bruce?";
    isFile = ( builtins.isPath pdefs ) || ( builtins.isString pdefs );
  in if isFile then fromFile else {
    config = if builtins.isAttrs pdefs then fromAttrs else fromList;
  };


# ---------------------------------------------------------------------------- #

in {
  inherit addPdefs;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
