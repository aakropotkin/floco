# ============================================================================ #
#
# Produces a `node_moules/' tree from either a `pathTree' or `keyTree' and
# `flocoPackages' structure(s).
#
# This is a draft implementation based on the `mkNmDirCmd' builder in
# `github:aameen-tulip/at-node-nix', deferring to `install-module.sh' to do
# most processing.
#
# This implementation makes no attempt to optimize the install process using
# package metadata making it slow but reliable.
# This should serve as a baseline for optimized implementations that leverage
# known pacakge/module information to flatten/inline calls to `cp' and `ln'.
# While those optimizations make a significant impact on performance; they are
# difficult to trace, and having "ol' reliable" available in times of need is
# a necessity.
#
# ---------------------------------------------------------------------------- #

let

  nixpkgs = ( import ../inputs ).nixpkgs.flake;

  keyToPath = lib: fpkgs: key: let
    pkg = lib.findFirst ( v: v.key == key ) fpkgs;
  in pkg.prepared.outPath;

in {
  lib       ? import ../lib { inherit (nixpkgs) lib; }
, system    ? builtins.currentSystem
, coreutils ? nixpkgs.legacyPackages.${system}.coreutils
, findutils ? nixpkgs.legacyPackages.${system}.findutils
, jq        ? nixpkgs.legacyPackages.${system}.jq
, bash      ? nixpkgs.legacyPackages.${system}.bash
# TODO: make this a setup-hook or `bin/' executable.
, install_module ? ../setup/install-module.sh

# XXX:
# You may wish to use `nixpkgs.legacyPackages.<SYSTEM>.writeText' if you intend
# to use this builder in a `devShell' to avoid a bug in `nix develop' that fails
# to create temporary files referenced by builders.
, toFile ? builtins.toFile

# Pairs of `{ "node_modules/@foo/bar" = "@foo/bar/1.0.0"; ... }' pairs.
# Optional if `pathTree' is given.
#
# NOTE: Paths are installed regardless of whether their associated
# package/module is supported - you must filter out unsupported keys before
# calling this builder.
, keyTree ? null
# Used to lookup keys from `keyTree', mapping them to store paths.
, flocoPackages ? null

# Optional if `keyTree' and `flocoPackages' is given.
, pathTree ?
  builtins.mapAttrs ( _: keyToPath lib flocoPackages.packages ) keyTree

, name ? "node_modules"
}: let

# ---------------------------------------------------------------------------- #

  checkDotDot = let
    check = p: ! ( lib.hasPrefix "../" p );
  in x:
    if builtins.all check ( builtins.attrNames pathTree ) then x else
    throw "tree: Encountered `../*' path in `pathTree'.";

  drv = derivation {
    inherit name system install_module;
    builder = "${bash}/bin/bash";
    PATH    = "${coreutils}/bin:${findutils}/bin:${jq}/bin:${bash}/bin";
    argFile = let
      procL  = to: [pathTree.${to} " \"$out/" to "\"\n"];
      linesL = builtins.concatMap procL ( builtins.attrNames pathTree );
      body   = builtins.concatStringsSep "" linesL;
    in toFile "node_modules-tree-argfile" body;
    args = ["-ec" ''
      while read -r args; do
        eval "bash $install_module -t $args";
      done <"$argFile"
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

in checkDotDot drv


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
