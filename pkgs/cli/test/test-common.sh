#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}";
export REALPATH;

# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}/../src/lib"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Load common helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../src/lib/common.sh
. "$FLOCO_LIBDIR/common.sh";

# ---------------------------------------------------------------------------- #

echo "SPATH: $SPATH";
echo "SDIR: $SDIR";
echo "_as_me: $_as_me";
echo "system: $( nixSystem; )";


# ---------------------------------------------------------------------------- #

flocoRef;


# ---------------------------------------------------------------------------- #

mktmmpAuto -d;
(
  cd "$_tmpAuto" >/dev/null||exit;
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
