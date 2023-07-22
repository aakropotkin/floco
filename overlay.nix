final: prev: {

  lib = import ./lib { inherit (prev) lib; };

  # Try to use `nodejs-14_x', then `nodejs-16_x', falling back to `nodejs'.
  # If the package is missing or marked as unavailable ( usually resulting from
  # a users `nixpkgs.config.permittedInsecurePackages' setting ).
  nodePackage = let
    # If a package is marked as available use it, otherwise fall back to a
    # second option.
    ifAvailableOr = attrName: fallback: let
      a = builtins.getAttr attrName final;
    in if ! ( builtins.hasAttr attrName final )  then fallback else
       if ( ( a.meta or {} ).available or true ) then a        else fallback;
  in ifAvailableOr "nodejs-14_x" ( ifAvailableOr "nodejs-16_x" final.nodejs );

  inherit (import ./setup {
    inherit (final) system bash coreutils findutils jq gnused nodePackage;
  }) floco-utils floco-hooks;

  inherit (import ./updaters {
    nixpkgs   = throw "floco: Nixpkgs should not be referenced from flake";
    nix-flake = throw "floco: Nix should not be referenced from flake";
    inherit (final) system bash coreutils jq gnused nix nodePackage;
    npm      = final.nodePackage.pkgs.npm;
    flakeRef = ./.;
  }) floco-updaters;

  treeFor = import ./pkgs/treeFor {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) system lib nodePackage;
    pkgsFor = final;
  };

  semver = import ./fpkgs/semver {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) system lib nodePackage;
    pkgsFor = final;
  };

  pacote = import ./fpkgs/pacote {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) system lib;
    # XXX: this must be `14.x'
    nodePackage = final.nodejs-14_x;
    pkgsFor     = final;
  };

  arborist = import ./fpkgs/arborist {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) system lib nodePackage;
    pkgsFor = final;
  };

  floco-nix =
    prev.lib.makeOverridable ( import ./pkgs/nix-plugin/pkg-fun.nix ) {
      inherit (final)
        stdenv boost nlohmann_json treeFor semver bash darwin pkg-config nix
      ;
      # XXX: this must be `14.x'
      nodejs = final.nodejs-14_x;
      npm    = final.nodejs-14_x.pkgs.npm;
    };

  floco = prev.lib.makeOverridable ( import ./pkgs/cli/pkg-fun.nix ) {
    inherit (final) lib stdenv bash coreutils gnugrep jq makeWrapper sqlite nix;
    npm = final.nodePackage.pkgs.npm;
  };

  pkgslib = ( prev.pkgslib or {} ) // ( import ./pkgs/lib {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) lib system treeFor semver bash;
    pkgsFor = final;
  } );

  db = final.callPackage ./db/cli {};

}
