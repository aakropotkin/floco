# ============================================================================ #
#
# A `options.flocoPackages.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.pdefs = lib.mkOption {

    description = lib.mdDoc ''
      List of `pdef` metadata records for all known pacakges
      and modules.
      These records are used to generate build recipes and build plans.
    '';

    type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules                    = [../pdef];
    } ) );

    default = {};

    example = {
      lodash."4.17.21" = {
        key   = "lodash/4.17.21";
        "..." = "...";
      };
      "@babel/cli"."7.20.7" = {
        key = "@babel/cli/7.20.7";
        "..." = "...";
      };
    };
  };  # End `options.pdefs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
