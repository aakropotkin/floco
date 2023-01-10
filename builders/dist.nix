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
, lib       ? import ../lib { inherit (nixpkgs) lib; }
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, pacote    ? import ../fpkgs/pacote { inherit lib system pkgsFor; }
, bash      ? pkgsFor.bash
, coreutils ? pkgsFor.coreutils
, findutils ? pkgsFor.findutils

, doUnpatch        ? true
, unpatch_shebangs ? ../setup/unpatch-shebangs.sh

}: let

# ---------------------------------------------------------------------------- #

  drvNoUnpatch = derivation {
    inherit name system;
    builder = "${pacote}/bin/pacote";
    args    = ["--cache=./.cache" "tarball" src ( builtins.placeholder "out" )];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  drvUnpatch = derivation {
    inherit name system src unpatch_shebangs;
    builder = "${bash}/bin/bash";
    PATH    = "${coreutils}/bin:${pacote}/bin:${findutils}/bin:${bash}/bin";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      pacote --cache=./.cache extract "$src" ./package;
      find ./package -type f -perm -0100                        \
                     -exec bash -eu "$unpatch_shebangs" {} \+;
      pacote --cache=./.cache tarball ./package "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  drv = if doUnpatch then drvUnpatch else drvNoUnpatch;


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
