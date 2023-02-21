# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ system
, bash
, semver
, nodejs

, rangeA
, rangeB
}: let

# ---------------------------------------------------------------------------- #

  sorted = builtins.sort builtins.lessThan [rangeA rangeB];

  drv = derivation {
    name = "semver-intersects";
    inherit system;
    rangeA    = builtins.head sorted;
    rangeB    = builtins.elemAt sorted 1;
    builder   = "${bash}/bin/bash";
    PATH      = "${nodejs}/bin";
    NODE_PATH = "${semver}/lib/node_modules";
    args      = ["-eu" "-o" "pipefail" "-c" ''
      node -e '
        const semver = require("semver");
        console.log(
          semver.intersects( process.env.rangeA, process.env.rangeB )
        );
      ' > "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  f = builtins.readFile drv.outPath;
  s = builtins.unsafeDiscardStringContext f;

# ---------------------------------------------------------------------------- #

in s == "true\n"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
