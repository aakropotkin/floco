# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs       ? builtins.getFlake "nixpkgs"
, system        ? builtins.currentSystem
, pkgsFor       ? nixpkgs.legacyPackages.${system}
, stdenv        ? pkgsFor.stdenv
, sqlite        ? pkgsFor.sqlite
, pkg-config    ? pkgsFor.pkg-config
, nlohmann_json ? pkgsFor.nlohmann_json
, curlpp        ? pkgsFor.curlpp
, curl          ? pkgsFor.curl
}: import ./pkg-fun.nix {
  inherit stdenv sqlite pkg-config nlohmann_json curlpp curl;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
