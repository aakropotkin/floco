# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib     ? import ../../lib { inherit (nixpkgs) lib; }
, nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, system  ? args.pkgsFor.system or builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}.extend ( import ../../overlay.nix )
, semver  ? pkgsFor.semver
, nodejs  ? pkgsFor.nodejs-18_x
, treeFor ? pkgsFor.semver
, bash    ? pkgsFor.bash
, ...
} @ args: {

  semver = import ./semver {
    inherit lib nixpkgs system pkgsFor semver nodejs bash;
  };

  treeFor = src: import ./tree-for.nix { inherit lib system bash treeFor src; };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
