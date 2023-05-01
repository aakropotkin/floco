#! /usr/bin/env bash
# ============================================================================ #
#
# Set `FLOCO_*DIR' variables.
#
# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo "common.sh: You must source this script, it is not runnable." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_dirs_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${REALPATH:=realpath}";
export REALPATH;


# ---------------------------------------------------------------------------- #

FLOCO_LIBDIR="$( $REALPATH "${BASH_SOURCE[0]%/*}"; )";
FLOCO_LIBEXECDIR="$( $REALPATH "$FLOCO_LIBDIR/../libexec"; )";
FLOCO_NIXDIR="$( $REALPATH "$FLOCO_LIBDIR/../nix"; )";
FLOCO_NIX_LIBDIR="$( $REALPATH "$FLOCO_NIXDIR/lib"; )";
export FLOCO_LIBDIR FLOCO_LIBEXECDIR FLOCO_NIXDIR FLOCO_NIX_LIBDIR;


# ---------------------------------------------------------------------------- #

: "${SPATH=}";
: "${SDIR=}";
: "${_as_me=}";
  export SPATH SDIR _as_me;

# setScriptVars "$0" "${BASH_SOURCE[@]}"
# --------------------------------------
# Set variables used to locate the originally invoked script.
# Takes `$0' and `${BASH_SOURCE[@]}' as args, and sets the following:
#   SPATH   Absolute path to the original script invoked.
#   SDIR    Absolute path to the directory containing the original script.
#   _as_me  Basename of the original script.
setScriptVars() {
  local _z;
  _z="$1";
  shift;
  if [[ "$#" -gt 0 ]]; then
    : "${SPATH:=$( $REALPATH "$1"; )}";
  else
    : "${SPATH:=$( $REALPATH "$( command -v "$_z"; )"; )}";
  fi
  : "${SDIR:=${SPATH%/*}}";
  : "${_as_me:=${SPATH##*/}}";
  export SPATH SDIR _as_me;
}
export -f setScriptVars;


# ---------------------------------------------------------------------------- #

export _floco_cli_dirs_sourced=:;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
