#! /usr/bin/env bash
# ============================================================================ #
#
# TODO: Replace `NAME', `FUNCTION', and `DESCRIPTION'.
# TODO: Replace or remove reference to `HELPER.sh'.
# TODO: remove `shellcheck disable=1091'.
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_NAME_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}"
export REALPATH;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source Helpers

#shellcheck disable=SC1091
#shellcheck source-path=SCRIPTDIR
#shellcheck source=./HELPER.sh
. "$FLOCO_LIBDIR/HELPER.sh";


# ---------------------------------------------------------------------------- #


# FUNCTION ARGS
# -------------
# DESCRIPTION
FUNCTION() {
  echo "TODO";
}
export -f FUNCTION;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Make this file usable as a script.
  FUNCTION "$@";
else
  export _floco_cli_NAME_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
