#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

# shellcheck source=./common.sh
. "${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/common.sh}";

# ---------------------------------------------------------------------------- #

echo "SPATH: $SPATH";
echo "SDIR: $SDIR";
echo "_as_me: $_as_me";
echo "system: $( nixSystem; )";


# ---------------------------------------------------------------------------- #

flocoRef;


# ---------------------------------------------------------------------------- #

(
  cd "$( mktmpAuto -d; )" >/dev/null;
  echo '{
    inputs.floco.url = "github:aakropotkin/floco";
    outputs = _: {};
  }' > flake.nix;
  $NIX flake lock;
  unset _floco_ref;
  flocoRef;
);


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
