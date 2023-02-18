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
, treeFor ? pkgsFor.semver
, bash    ? pkgsFor.bash
, ...
} @ args: {

  semverRangeFilt = range: versions: import ./semver.nix {
    inherit system bash semver range versions;
  };

  treeFor = src: import ./tree-for.nix {
    inherit lib system bash treeFor src;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
