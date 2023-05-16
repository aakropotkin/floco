# ============================================================================ #
#
# Produces a Nix Plugin with some `floco' extensions.
#
# Example plugin invocation ( for a trivial hello world plugin )
# NOTE: use `libhello.dylib' on Darwin.
# $ nix --option plugin-files './result/libexec/libhello.so' eval  \
#       --expr 'builtins.hello'
#   "Hello, World!"
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? ( import ../../inputs ).nixpkgs.flake
, lib       ? nixpkgs.lib
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, stdenv    ? pkgsFor.stdenv
, nix-flake ?
  builtins.getFlake "github:NixOS/nix/${builtins.nixVersion or "2.14.1"}"
, boost         ? pkgsFor.boost
, nlohmann_json ? pkgsFor.nlohmann_json
, pkg-config    ? pkgsFor.pkg-config
, treeFor       ? import ../treeFor { inherit nixpkgs system pkgsFor; }
, semver        ? import ../../fpkgs/semver { inherit nixpkgs system pkgsFor; }
, nodejs        ? pkgsFor.nodejs-14_x
, npm           ? nodejs.pkgs.npm
, bash          ? pkgsFor.bash
, nix           ? nix-flake.packages.${system}.nix
, darwin        ? pkgsFor.darwin
}: import ./pkg-fun.nix {
  inherit
    stdenv
    boost
    nlohmann_json
    treeFor
    semver
    nodejs
    npm
    bash
    nix
    darwin
    pkg-config
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
