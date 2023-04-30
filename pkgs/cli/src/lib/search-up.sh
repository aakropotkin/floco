#! /usr/bin/env bash
# ============================================================================ #
#
# Helper function which searches for a file in a directory and in its parent
# directories until it is located or the project/filesystem root is reached.
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_search_up_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}";
export REALPATH;


# ---------------------------------------------------------------------------- #

# stopSearch DIR
# --------------
# Return 0 if DIR's parent is searchable, 1 otherwise.
keepSearching() {
  ! { [[ "$( $REALPATH "$1"; )" = '/' ]] || [[ -d "$1/.git" ]]; };
}
export -f keepSearching;


# searchUp FILE [DIR]
# -------------------
searchUp() {
  if [[ -r "${2:-$PWD}/$1" ]]; then
    $REALPATH "${2:-$PWD}/$1";
  elif keepSearching "${2:-$PWD}"; then
    searchUp "$1" "${2:-$PWD}/..";
  else
    return 1;
  fi
}
export -f searchUp;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Make this file usable as a script.
  if [[ "$#" -gt 2 ]] || [[ "$#" -lt 1 ]]; then
    echo "floco-ref.sh: You may pass one or two arguments." >&2;
    exit 1;
  fi
  searchUp "$@";
else
  export _floco_cli_search_up_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
