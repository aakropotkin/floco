# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description = "Yet another Nix+Node.js framework";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, ... } @ inputs: let

# ---------------------------------------------------------------------------- #

    supportedSystems = [
      "x86_64-linux"  "aarch64-linux"  "i686-linux" 
      "x86_64-darwin" "aarch64-darwin"
    ];

    eachSupportedSystemMap = f: builtins.foldl' ( acc: system: acc // {
      ${system} = f system;
    } ) {} supportedSystems;


# ---------------------------------------------------------------------------- #

    overlays.floco   = import ./overlay.nix;
    overlays.default = overlays.floco;


# ---------------------------------------------------------------------------- #

    nixosModules.floco = import ./modules/top;

    nixosModules.plockToPdefs = { lib, lockDir, basedir, ... }: {
      imports = [./modules/top];
      config._module.args.basedir = lib.mkDefault lockDir;
      options.floco = lib.mkOption {
        type = lib.types.submoduleWith {
          shorthandOnlyDefinesConfig = false;
          modules = [
            ./modules/plockToPdefs
            {
              config._module.args.basedir = basedir;
              config.lockDir = lib.mkDefault lockDir;
            }
          ];
        };
      };
    };


# ---------------------------------------------------------------------------- #

  in {  # Begin `outputs'

# ---------------------------------------------------------------------------- #

    lib = import ./lib { inherit (nixpkgs) lib; };

# ---------------------------------------------------------------------------- #

    inherit overlays nixosModules;

# ---------------------------------------------------------------------------- #

    packages = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
    in {
      inherit (pkgsFor)
        floco
        floco-utils
        floco-hooks
        floco-updaters
        treeFor
        semver
        pacote
      ;
    } );


# ---------------------------------------------------------------------------- #

    apps = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
    in {

      fromPlock = {
        type    = "app";
        program = "${pkgsFor.floco-updaters}/bin/npm-plock.sh";
      };

      fromRegistry = {
        type    = "app";
        program = "${pkgsFor.floco-updaters}/bin/from-registry.sh";
      };

    } );


# ---------------------------------------------------------------------------- #

    templates = let
      basic = {
        description = "a legacy style `default.nix' project.";
        path        = ./templates/basic;
      };
    in {
      inherit basic;
      default = basic;
      fillPins = {
        description = "Expression for filling missing `pin's in `pdefs.nix'.";
        path        = ./templates/fill-pins;
      };
    };


# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
