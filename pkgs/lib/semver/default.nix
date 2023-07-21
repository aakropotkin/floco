# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib     ? import ../../../lib { inherit (nixpkgs) lib; }
, nixpkgs ? ( import ../../../inputs ).nixpkgs.flake
, system  ? args.pkgsFor.system or builtins.currentSystem
, pkgsFor ?
  nixpkgs.legacyPackages.${system}.extend ( import ../../../overlay.nix )
, semver ? pkgsFor.semver
, nodejs ? pkgsFor.nodejs-18_x
, bash   ? pkgsFor.bash
, ...
} @ args: {

  # Filter a list of versions to only those that satisfy a given semver range.
  rangeFilter = range: versions: import ./range-filt.nix {
    inherit system bash semver range versions;
  };

  # Validate and normalize a version range.
  # This will convert `node-semver' extensions to the standard format to
  # `semver' 2.0.0 complaint ranges.
  #   - '~1.0.0' -> '>=1.0.0 <1.1.0-0'
  #   - '^1.0.0' -> '>=1.0.0 <2.0.0-0'
  rangeValid = range: import ./valid.nix {
    inherit system bash semver nodejs range;
  };

  # Do `rangeA' and `rangeB' overlap?
  rangeIntersects = rangeA: rangeB: import ./intersects.nix {
    inherit system bash semver nodejs rangeA rangeB;
  };

  # Is `rangeA' a subset of `rangeB'?
  rangeSubset = rangeA: rangeB: import ./subset.nix {
    inherit system bash semver nodejs rangeA rangeB;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
