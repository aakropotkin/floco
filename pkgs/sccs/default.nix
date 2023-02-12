# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs       ? ( import ../../inputs ).nixpkgs.flake
, lib           ? nixpkgs.lib
, system        ? builtins.currentSystem
, pkgsFor       ? nixpkgs.legacyPackages.${system}
, stdenv        ? pkgsFor.stdenv
, nlohmann_json ? pkgsFor.nlohmann_json
, callPackage   ? pkgsFor.callPackage
}: callPackage ./pkg-fun.nix { inherit stdenv nlohmann_json; }


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
