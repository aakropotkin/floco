# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ system
, bash
, semver
, range
, versions
}: let

# ---------------------------------------------------------------------------- #

  drv = derivation {
    name = "semver-range-check";
    inherit system range versions;
    builder = "${bash}/bin/bash";
    PATH    = "${semver}/bin";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      semver -r "$range" $versions > "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  s = builtins.split "\n" ( builtins.readFile drv.outPath );

# ---------------------------------------------------------------------------- #

in builtins.filter ( v: ( builtins.isString v ) && ( v != "" ) ) s


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
