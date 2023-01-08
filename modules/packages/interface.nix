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

      # NOTE: modifying the `getSubOptions' routine isn't working here.
      # I have no idea why but the issue is relatively benign since it only
      # effects documentation generation.
      # Nonetheless I'm leaving it until it can be properly debugged.
      type = let
        pkgType = nt.submoduleWith {
          shorthandOnlyDefinesConfig = true;
          modules = [
            { config._module.args = { inherit pkgs; flocoPackages = config; }; }
            ../package
          ];
        };
      in nt.attrsOf ( nt.attrsOf pkgType );

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
