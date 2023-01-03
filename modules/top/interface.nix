# ============================================================================ #
#
# Top level `flocoPackages' module.
#
# ---------------------------------------------------------------------------- #

{ lib    ? import ../../lib { inherit (pkgs) lib; }
, config
, system ? config._module.args.system or builtins.currentSystem
, pkgs   ? config._module.args.pkgs or
           ( import ../../inputs ).nixpkgs.flake.legacyPackages.${system}
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
      shorthandOnlyDefinesConfig = true;
      modules = [
        { config._module.args = { inherit pkgs; }; }
        ../pdefs
        ../packages
      ];
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
