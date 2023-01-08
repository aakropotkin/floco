# ============================================================================ #
#
# Uses `pacote' to produce a distributable tarball.
# `src' should be a "built" source tree ready for publishing to a registry.
#
# ---------------------------------------------------------------------------- #

let
  nixpkgs = ( import ../inputs ).nixpkgs.flake;
in {
  name ? ( baseNameOf pjs.name ) + "-" + pjs.version + ".tgz"
, pjs  ? lib.importJSON ( src + "/package.json" )
, src
, lib     ? import ../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, pacote  ? import ../fpkgs/pacote { inherit lib system pkgsFor; }
}: let

# ---------------------------------------------------------------------------- #

  drv = derivation {
    inherit name system;
    builder = "${pacote}/bin/pacote";
    args    = ["--cache=./.cache" "tarball" src ( builtins.placeholder "out" )];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

in drv // {
  meta = {
    inherit name;
    pname = baseNameOf pjs.name;
    inherit (pjs) version;
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
