# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description = "Yet another Nix+Node.js framework";

  inputs.nix.url = "github:NixOS/nix/2.12.0";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, nix, ... } @ inputs: let

# ---------------------------------------------------------------------------- #

    supportedSystems = [
      "x86_64-linux"  "aarch64-linux"  "i686-linux" 
      "x86_64-darwin" "aarch64-darwin"
    ];

    eachSupportedSystemMap = f: builtins.foldl' ( acc: system: acc // {
      ${system} = f system;
    } ) {} supportedSystems;


# ---------------------------------------------------------------------------- #

    overlays.default = overlays.floco;
    overlays.floco = final: prev: {
      lib = import ./lib { inherit (prev) lib; };
      inherit (import ./setup {
        inherit (final) system bash coreutils findutils jq gnused;
        nodejs = final.nodejs-slim-14_x;
      }) floco-utils;
      treeFor = import ./pkgs/treeFor {
        nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
        inherit (final) system lib;
        pkgsFor = final;
      };
      semver = import ./fpkgs/semver {
        nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
        inherit (final) system lib;
        pkgsFor = final;
      };
      pacote = import ./fpkgs/pacote {
        nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
        inherit (final) system lib;
        pkgsFor = final;
      };
      floco = import ./pkgs/nix-plugin {
        nixpkgs   = throw "floco: Nixpkgs should not be referenced from flake";
        nix-flake = throw "floco: Nix should not be referenced from flake";
        inherit (final) system boost treeFor semver bash;
        pkgsFor   = final;
        npm       = final.nodejs-14_x.pkgs.npm;
        inherit (nix.packages.${final.system}) nix;
      };
    };


# ---------------------------------------------------------------------------- #

    nixosModules = {
      floco = { config, pkgs, ... }: {
        imports = [./modules/top];
        config._module.specialArgs.lib = import ./lib {
          inherit (nixpkgs) lib;
        };
        config._module.args.pkgs = pkgs.extend overlays.default;
      };
    };


# ---------------------------------------------------------------------------- #

  in {  # Begin `outputs'

    lib = import ./lib { inherit (nixpkgs) lib; };

    inherit overlays nixosModules;

    packages = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
    in {
      inherit (pkgsFor)
        floco
        floco-utils
        treeFor
        semver
        pacote
      ;
    } );

# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
