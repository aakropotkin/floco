# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs     ? ( import ../../inputs ).nixpkgs.flake
, system      ? builtins.currentSystem
, pkgsFor     ? nixpkgs.legacyPackages.${system}
, lib         ? nixpkgs.lib
, stdenv      ? pkgsFor.stdenv
, bash        ? pkgsFor.bash
, coreutils   ? pkgsFor.coreutils
, gnugrep     ? pkgsFor.gnugrep
, jq          ? pkgsFor.jq
, makeWrapper ? pkgsFor.makeWrapper
, nix         ? pkgsFor.nix
, npm         ? pkgsFor.nodejs-14_x.npm
, sqlite      ? pkgsFor.sqlite
}: lib.makeOverridable ( import ./pkg-fun.nix ) {
  inherit lib stdenv bash coreutils gnugrep jq makeWrapper nix npm sqlite;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
