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

#FLOCO_MANIFEST_DB_VERSION=1;
#FLOCO_PDEFS_DB_VERSION=1;
#FLOCO_FETCH_INFO_DB_VERSION=1;
#FLOCO_TREE_INFO_DB_VERSION=1;


# ---------------------------------------------------------------------------- #

FLOCO_MDB="$FLOCO_DBDIR/manifests.db";
FLOCO_PDB="$FLOCO_DBDIR/pdefs.db";
FLOCO_FDB="$FLOCO_DBDIR/fetch-info.db";
export FLOCO_MDB FLOCO_PDB FLOCO_FDB;

#FLOCO_TDB="$FLOCO_DBDIR/tree-info.db";
#FLOCO_TDB;


# ---------------------------------------------------------------------------- #

# pdb_init PATH
# -------------
# Create a new `pdefs.db'
pdb_init() {
  local _db;
  _db="${1:-$PWD/pdefs.db}";
  if [[ -d "$_db" ]]; then
    _db="$_db/pdefs.db";
  fi
  $SQLITE "$_db" < "$FLOCO_SQLDIR/pdefs.sql";
}
export -f pdb_init;


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

# pdb_run [PATH] ARGS
# -------------------
# Run `sqlite3' commands directly on a `pdefs.db'
pdb_run() {
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
export -f pdb_run;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  _cmd="$1";
  shift;
  case "$_cmd" in
    init)   pdb_init "$@"; ;;
    run)    pdb_run "$@"; ;;
    # add)    db_add "$@"; ;;
    # remove) db_remove "$@"; ;;
    # show)   db_show "$@"; ;;
    *)
      echo "floco:lib/db.sh: Unrecognized command '$_cmd'." >&2;
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
