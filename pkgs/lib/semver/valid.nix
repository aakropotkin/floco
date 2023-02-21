# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ system
, bash
, semver
, nodejs
, range
}: let

# ---------------------------------------------------------------------------- #

  validRangeDrv = derivation {
    name = "semver-valid-range";
    inherit system range;
    builder   = "${bash}/bin/bash";
    PATH      = "${nodejs}/bin";
    NODE_PATH = "${semver}/lib/node_modules";
    args      = ["-eu" "-o" "pipefail" "-c" ''
      node -e '
        console.log( require( "semver/ranges/valid.js" )( process.env.range ) );
      ' > "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  f = builtins.readFile validRangeDrv.outPath;
  s = builtins.unsafeDiscardStringContext f;
  l = builtins.stringLength s;

# ---------------------------------------------------------------------------- #

in builtins.substring 0 ( l - 1 ) s


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
