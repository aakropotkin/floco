# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs    ? builtins.getFlake "nixpkgs"
, system     ? builtins.currentSystem
, pkgsFor    ? nixpkgs.legacyPackages.${system}
, stdenv     ? pkgsFor.stdenv
, sqlite     ? pkgsFor.sqlite
, pkg-config ? pkgsFor.pkg-config
}: import ./pkg-fun.nix { inherit stdenv sqlite pkg-config; }


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
