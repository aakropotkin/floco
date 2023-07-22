final: prev: {

  lib = import ./lib { inherit (prev) lib; };

  nodePackage = final.nodejs;

  # TODO: 2023-07-22 `npm-9.8.0' fails to build because of failures in `man-db'
  # ( a dependency of `util-linux' ).
  # Remove this block when it has been fixed upstream.
  npm = final.nodePackage.pkgs.npm.overrideAttrs ( aprev: let
    # Disable manpage translation for `util-linux' dependency.
    # This isn't passed in as an arg to `npm', so we search for it in
    # `buildInputs' and apply our override "in place".
    replace = drv:
      if ( drv.pname or drv.name ) != "util-linux" then drv else
      drv.override { translateManpages = false; };
  in {
    buildInputs = map replace aprev.buildInputs;
  } );

  inherit (import ./setup {
    inherit (final) system bash coreutils findutils jq gnused nodePackage;
  }) floco-utils floco-hooks;

  inherit (import ./updaters {
    nixpkgs   = throw "floco: Nixpkgs should not be referenced from flake";
    nix-flake = throw "floco: Nix should not be referenced from flake";
    flakeRef  = ./.;
    inherit (final) system bash coreutils jq gnused nix nodePackage npm;
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
    inherit (final) system lib nodePackage;
    pkgsFor = final;
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
        npm
      ;
      nodejs = final.nodePackage;
    };

  floco = prev.lib.makeOverridable ( import ./pkgs/cli/pkg-fun.nix ) {
    inherit (final)
      lib stdenv bash coreutils gnugrep jq makeWrapper sqlite nix npm
    ;
  };

  pkgslib = ( prev.pkgslib or {} ) // ( import ./pkgs/lib {
    nixpkgs = throw "floco: Nixpkgs should not be referenced from flake";
    inherit (final) lib system treeFor semver bash;
    pkgsFor = final;
  } );

}
