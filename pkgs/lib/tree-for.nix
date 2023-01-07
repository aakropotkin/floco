# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, system
, treeFor
, bash
, src
}: let

# ---------------------------------------------------------------------------- #

  timestamp = toString builtins.currentTime;

  drv = derivation {
    name = let
      suff = if builtins.pathExists "${src}/package-lock.json" then "" else
             "-" + timestamp;
    in "tree-for${suff}.json";
    inherit system src;
    builder = "${bash}/bin/bash";
    PATH    = "${treeFor}/bin";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      treeFor "$src" > "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

in lib.importJSON drv.outPath


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
