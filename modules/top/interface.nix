# ============================================================================ #
#
# Top level `flocoPackages' module.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, pkgs, ... }: let
  nt = lib.types;
in {

# ---------------------------------------------------------------------------- #

  options.flocoPackages = lib.mkOption {
    description = lib.mdDoc ''
      Scope used for configuring `flocoPackages` framework.
    '';
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        {
          config._module.args = { inherit pkgs; };
        }
        ../pdefs
        ../packages
      ];
    };
    default = let
      subs = options.flocoPackages.type.getSubOptions [];
    in builtins.mapAttrs ( _: s: s.default ) ( removeAttrs subs ["_module"] );
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
