# ============================================================================ #
#
# Coerce a collection of `pdef' records to a set of config fields.
#
# If the argument is already an attrset this is a no-op.
# If the argument is a list its members will be treated as a module list to
# be merged.
# If the argument is a file it will be imported and processed as described
# above, except that certain fields will be normalized to account for
# serialization compression.
#
# This routine exists to simplify aggregation of `pdefs.nix' files.
#
# Returns a `config.flocoPackages.pdefs.<IDENTS.<VERSION>' attrset.
#
# ---------------------------------------------------------------------------- #

{ lib ? ( builtins.getFlake "nixpkgs" ).lib }: let

# ---------------------------------------------------------------------------- #

  addPdefs = pdefs: let
    fromFile = let
      raw = import pdefs;
      normalize = v:
        if ! ( v ? treeInfo ) then v else
        lib.recursiveUpdate { metaFiles.metaRaw = { inherit (v) treeInfo; }; }
                            ( removeAttrs v ["treeInfo"] );
      norm = if builtins.isList raw then map normalize raw else
             builtins.mapAttrs ( _: builtins.mapAttrs ( _: normalize ) ) raw;
    in addPdefs norm;
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

in addPdefs


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
