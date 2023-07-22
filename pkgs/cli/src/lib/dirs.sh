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

: "${HOME:=/homeless/shelter}";
export HOME;


# ---------------------------------------------------------------------------- #

: "${XDG_CACHE_HOME:=$HOME/.cache}";
: "${XDG_CONFIG_HOME:=$HOME/.config}";
: "${XDG_DATA_HOME:=$HOME/.local/share}";
: "${XDG_STATE_HOME:=$HOME/.local/state}";
export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_STATE_HOME;


# ---------------------------------------------------------------------------- #

: "${FLOCO_CACHEDIR:=$XDG_CACHE_HOME/floco}";
: "${FLOCO_DATADIR:=$XDG_DATA_HOME/floco}";
: "${FLOCO_STATEDIR:=$XDG_STATE_HOME/floco}";
: "${FLOCO_DBDIR:=$FLOCO_CACHEDIR/dbs}";
export FLOCO_CACHEDIR FLOCO_DATADIR FLOCO_STATEDIR FLOCO_DBDIR;


# ---------------------------------------------------------------------------- #

FLOCO_LIBDIR="$( $REALPATH "${BASH_SOURCE[0]%/*}"; )";
FLOCO_LIBEXECDIR="$( $REALPATH "$FLOCO_LIBDIR/../libexec"; )";
FLOCO_NIXDIR="$( $REALPATH "$FLOCO_LIBDIR/../nix"; )";
FLOCO_NIX_LIBDIR="$( $REALPATH "$FLOCO_NIXDIR/lib"; )";
FLOCO_SQLDIR="$( $REALPATH "$FLOCO_LIBDIR/../site-sql"; )";
export FLOCO_LIBDIR FLOCO_LIBEXECDIR FLOCO_NIXDIR FLOCO_NIX_LIBDIR FLOCO_SQLDIR;


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
