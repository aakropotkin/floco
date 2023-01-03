# ============================================================================ #
#
# A `options.flocoPackages.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, pkgs   ? config._module.args.pkgs
, ...
}: let
  nt = lib.types;
in {

# ---------------------------------------------------------------------------- #

  options.flocoPackages = lib.mkOption {
    description = lib.mdDoc ''
      Scope used for configuring `flocoPackages` framework.
    '';
    type = nt.submoduleWith {
      modules = [
        {
          config._module.args.pkgs = pkgs;
          options.pdefs = lib.mkOption {
            description = lib.mdDoc ''
              List of `pdef` metadata records for all known pacakges
              and modules.
              These records are used to generate build recipes and build plans.
            '';

            type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
              modules = [../pdef];
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
          };  # End `options.flocoPackages.pdefs'
        }

        ( { pkgs, config, ... }: {
          options.packages = lib.mkOption {
            description = lib.mdDoc ''
              Collection of built/prepared packages and modules.
            '';
            type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
              modules = [
                ../package
                {
                  config._module.args = {
                    inherit pkgs;
                    flocoPackages = config;
                  };
                }
              ];
            } ) );
          };
        } )

      ];  # End `options.flocoPackages.pdefs.modules'

    };  # End `options.flocoPackages'
  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
