#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_db_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}";
: "${SQLITE:=sqlite3}";
export REALPATH SQLITE;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source Helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./dirs.sh
. "$FLOCO_LIBDIR/dirs.sh";
#shellcheck source-path=SCRIPTDIR
#shellcheck source=./search-up.sh
. "$FLOCO_LIBDIR/search-up.sh";


# ---------------------------------------------------------------------------- #

# db_init PATH
# ------------
# Create a new `pdefs.db'
db_init() {
  local _db;
  _db="${1:-$PWD/pdefs.db}";
  if [[ -d "$_db" ]]; then
    _db="$_db/pdefs.db";
  fi
  $SQLITE "$_db" < "$FLOCO_SQLDIR/pdefs.sql";
}
export -f db_init;


# ---------------------------------------------------------------------------- #

# is_sql_db PATH
# --------------
# Predicate used to detect if a path is a SQLite database.
is_sql_db() {
  local _magic;
  if [[ -d "$1" ]]; then return 1; fi
  if ! [[ -r "$1" ]]; then return 1; fi
  read -rn 6 _magic < "$1";
  [[ "$_magic" = 'SQLite' ]];
}


# ---------------------------------------------------------------------------- #

# db_run [PATH] ARGS
# ------------------
# Run `sqlite3' commands directly on a `pdefs.db'
db_run() {
  local _db;
  if [[ -r "$1/pdefs.db" ]]; then
    _db="$1/pdefs.db";
    shift;
  elif is_sql_db "$1"; then
    _db="$1";
    shift;
  else
    _db="$( searchUp pdefs.db "$PWD"||:; )";
    if [[ -z "$_db" ]]; then
      echo "${_as_me:-floco:lib/db.sh}: Could not locate \`pdefs.db'." >&2;
      exit 1;
    fi
  fi
  $SQLITE "$_db" "$@";
}
export -f db_run;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  _cmd="$1";
  shift;
  case "$_cmd" in
    init)   db_init "$@"; ;;
    run)    db_run "$@"; ;;
    # add)    db_add "$@"; ;;
    # remove) db_remove "$@"; ;;
    # show)   db_show "$@"; ;;
    *)
      echo "floco:lib/db.sh: Unrecognized command '$cmd'." >&2;
      exit 1;
    ;;
  esac
else
  export _floco_cli_db_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
