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

    nixosModules.default = nixosModules.floco;
    nixosModules.floco   = import ./modules/top;

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
        floco-nix
        floco-utils
        floco-hooks
        floco-updaters
        treeFor
        semver
        pacote
        arborist
      ;
      default = pkgsFor.floco;
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
        description = "a legacy style `default.nix' for a local project.";
        path        = ./templates/basic;
        welcomeText = ''
          Initialize your project by running:

          nix run floco#fromPlock -- -pt;


          Build with:

          nix build -f ./. -L global;
        '';
      };
    in {
      inherit basic;
      default = basic;
      fillPins = {
        description = "Expression for filling missing `pin's in `pdefs.nix'.";
        path        = ./templates/fill-pins;
      };
      registry = {
        description = "a legacy style `default.nix' for a registry package.";
        path        = ./templates/registry;
        welcomeText = ''
          Initialize your project by running:

          nix run floco#fromRegistry -- -pt <IDENT>@<VERSION>;

          echo '{ ident = "<IDENT>"; version = "<VERSION>"; }' > info.nix;


         Build with:

         nix build -f ./. -L;
        '';
      };
    };


# ---------------------------------------------------------------------------- #

    pkgsFor = let
      bySystem = eachSupportedSystemMap ( system:
        nixpkgs.legacyPackages.${system}.extend overlays.default
      );
    in bySystem // {
      __functor = pf: system:
        pf.${system} or (
          throw "floco#pkgsFor: Unsupported system: ${system}"
        );
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
