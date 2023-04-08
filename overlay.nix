final: prev: {

  lib = import ./lib { inherit (prev) lib; };

  inherit (import ./setup {
    inherit (final) system bash coreutils findutils jq gnused;
    nodejs = final.nodejs-slim-14_x;
  }) floco-utils floco-hooks;

  inherit (import ./updaters {
    nixpkgs   = throw "floco: Nixpkgs should not be referenced from flake";
    nix-flake = throw "floco: Nix should not be referenced from flake";
    inherit (final) system bash coreutils jq gnused;
    nodejs   = final.nodejs-slim-14_x;
    npm      = final.nodejs-14_x.pkgs.npm;
    nix      = final.nixVersions.nix_2_12;
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

  arborist = import ./fpkgs/arborist {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) system lib;
    pkgsFor = final;
  };

  floco-nix =
    prev.lib.makeOverridable ( import ./pkgs/nix-plugin/pkg-fun.nix ) {
      inherit (final) stdenv boost treeFor semver bash darwin;
      nodejs = final.nodejs-14_x;
      npm    = final.nodejs-14_x.pkgs.npm;
      nix    = final.nixVersions.nix_2_12;
    };

  floco = prev.lib.makeOverridable ( import ./pkgs/cli/pkg-fun.nix ) {
    inherit (final) lib stdenv bash coreutils gnugrep jq makeWrapper;
    nix = final.nixVersions.nix_2_12;
    npm = final.nodejs-14_x.pkgs.npm;
  };

  pkgslib = ( prev.pkgslib or {} ) // ( import ./pkgs/lib {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) lib system treeFor semver bash;
    pkgsFor = final;
  } );

}
