# ============================================================================ #
#
# Is `rangeA' a subset of `rangeB'?
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

  drv = derivation {
    name = "semver-subset";
    inherit system rangeA rangeB;
    builder   = "${bash}/bin/bash";
    PATH      = "${nodejs}/bin";
    NODE_PATH = "${semver}/lib/node_modules";
    args      = ["-eu" "-o" "pipefail" "-c" ''
      node -e '
        const semver = require("semver");
        console.log(
          semver.subset( process.env.rangeA, process.env.rangeB )
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
