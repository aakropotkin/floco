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

  rangeFiltDrv = derivation {
    name = "semver-range-filter";
    inherit system range;
    versions = builtins.sort builtins.lessThan versions;
    builder  = "${bash}/bin/bash";
    PATH     = "${semver}/bin";
    args     = ["-eu" "-o" "pipefail" "-c" ''
      semver -r "$range" $versions > "$out";
    ''];
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
  };


# ---------------------------------------------------------------------------- #

  f = builtins.readFile rangeFiltDrv.outPath;
  s = builtins.split "\n" ( builtins.unsafeDiscardStringContext f );

# ---------------------------------------------------------------------------- #

in builtins.filter ( v: ( builtins.isString v ) && ( v != "" ) ) s


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
