# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/top/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.floco = lib.mkOption {
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = false;
      modules = [
        ../records
        ( { config, ... }: {

          imports = [
            ../settings/implementation.nix
            ../buildPlan/implementation.nix
            ../topo/implementation.nix
            ../pdefs/implementation.nix
            ../packages/implementation.nix
            ../fetchers/implementation.nix
          ];

          config._module.args.pkgs = let
            nixpkgs = ( import ../../inputs ).nixpkgs.flake;
            pkgsFor = nixpkgs.legacyPackages.${config.settings.system};
            ov      = lib.composeExtensions
                        ( import ../../overlay.nix )
                        ( _: _: { inherit (config.settings) nodePackage; } );
            withOv  = pkgsFor.extend ov;
          in lib.mkOverride 999 withOv;

          config.settings.system = lib.mkIf (
            ( builtins.currentSystem or null ) == null
          ) ( lib.mkOverride 999 pkgs.system );

        } )
      ];
    };
  };


# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
