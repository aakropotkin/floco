final: prev: {

  lib = import ./lib { inherit (prev) lib; };

  inherit (import ./setup {
    inherit (final) system bash coreutils findutils jq gnused;
    nodejs = final.nodejs-slim-14_x;
  }) floco-utils;

  inherit (import ./updaters {
    nixpkgs   = throw "floco: Nixpkgs should not be referenced from flake";
    nix-flake = throw "floco: Nix should not be referenced from flake";
    inherit (final) system bash coreutils jq gnused;
    nodejs = final.nodejs-slim-14_x;
    npm    = final.nodejs-14_x.pkgs.npm;
    nix    = final.nixVersions.nix_2_12;
    flakeRef = ./.;
  }) floco-updaters;

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
    pkgsFor = final;
    npm     = final.nodejs-14_x.pkgs.npm;
    nix     = final.nixVersions.nix_2_12;
  };

}