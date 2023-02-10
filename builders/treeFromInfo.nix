# ============================================================================ #
#
#
# ---------------------------------------------------------------------------- #

let
  nixpkgs = ( import ../inputs ).nixpkgs.flake;
in {
  lib       ? import ../lib { inherit (nixpkgs) lib; }
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, coreutils ? pkgsFor.coreutils
, findutils ? pkgsFor.findutils
, jq        ? pkgsFor.jq
, bash      ? pkgsFor.bash
, writeText ? pkgsFor.writeText
# TODO: make this a setup-hook or `bin/' executable.
, install_module ? ../setup/install-module.sh

# NOTE: Paths are installed regardless of whether their associated
# package/module is supported - you must filter out unsupported keys before
# calling this builder.
, treeInfo ? null

# Used to pull packages
, packages ? null

# Used to pull package metadata
, pdefs ? null

, name ? "node_modules"
} @ args: let

# ---------------------------------------------------------------------------- #

  checkDotDot = let
    check = p: ! ( lib.hasPrefix "../" p );
  in x:
    if builtins.all check ( builtins.attrNames x.passthru.treeInfo ) then x else
    throw "tree: Encountered `../*' path in `pathTree'.";

  cmdFile = let
    procL = to: let
      key     = treeInfo.${to}.key;
      ident   = dirOf key;
      version = baseNameOf key;
      pkg     = packages.${ident}.${version};
      dir = if ! ( treeInfo.${to}.link or false ) then pkg.prepared.outPath else
            pkg.global.outPath + "/lib/node_modules/${ident}";
      pdef = lib.getPdef { inherit pdefs; } { inherit ident version; };
      env  = let
        binPairs' = if pdef.binInfo.binPairs == {} then {} else {
          BIN_PAIRS = let
            tuples = builtins.attrValues (
              builtins.mapAttrs ( n: p: "${n},${p}" ) pdef.binInfo.binPairs
            );
          in builtins.concatStringsSep " " tuples;
        };
        binDir' = if binPairs' != {} then {} else
                  if pdef.binInfo.binDir == null then {} else {
                    BIN_DIR = pdef.binInfo.binDir;
                  };
        binLinks' = if to == "node_modules/${ident}" then {} else {
          NO_BIN_LINKS = ":";
        };
        bin' = if ( binPairs' == {} ) && ( binDir' == {} ) then {
          NO_BINS  = ":";
          NO_PERMS = ":";
        } else binPairs' // binDir' // binLinks';
      in {
        IDENT    = ident;
        NO_PATCH = ":";
      } // bin';
      vars = builtins.concatStringsSep " " (
        lib.mapAttrsToList lib.toShellVar env
      );
      maybeLink = if treeInfo.${to}.link or false then "-C " else "";
    in [
      vars " bash $install_module -t " maybeLink dir " \"$out/" to "\"\n"
    ];
    linesL = builtins.concatMap procL ( builtins.attrNames treeInfo );
    body   = builtins.concatStringsSep "" linesL;
  in writeText "node_modules-tree-argfile" body;


  drv = derivation {
    inherit name system install_module;
    builder = "${bash}/bin/bash";
    PATH    = "${coreutils}/bin:${findutils}/bin:${jq}/bin:${bash}/bin";
    args = ["-eu" "-o" "pipefail" "-c" ( ''
      mkdir -p "$out/node_modules";
    '' + cmdFile.text )];
  };


# ---------------------------------------------------------------------------- #

  final = drv // { passthru = { inherit cmdFile treeInfo; }; };

in checkDotDot final


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
