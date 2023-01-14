# ============================================================================ #
#
# Top level `floco' module.
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.floco = lib.mkOption {
    description = lib.mdDoc ''
      Scope used for configuring `floco` framework.
    '';
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = false;
      modules = [
        ../pdef/deferred.nix
        ../pdefs/interface.nix
        ../packages/interface.nix
      ];
      specialArgs.lib =
        if lib ? libfloco then lib else import ../../lib { inherit lib; };
    };
    default = let
      subs = options.floco.type.getSubOptions [];
    in builtins.mapAttrs ( _: s: s.default ) ( removeAttrs subs ["_module"] );
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
