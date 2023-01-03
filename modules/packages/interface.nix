# ============================================================================ #
#
# A `options.flocoPackages.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

    options.packages = lib.mkOption {

      description = lib.mdDoc ''
        Collection of built/prepared packages and modules.
      '';

      type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [
          { config._module.args = { inherit pkgs; flocoPackages = config; }; }
          ../package
        ];
      } ) );

      default = builtins.mapAttrs ( _: builtins.mapAttrs ( _: pdef: {
        inherit pdef;
      } ) ) options.pdefs.default;

      example = {
        lodash."4.17.21" = {
          key = "lodash/4.17.21";
        };
      };

    };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
