#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;

# ---------------------------------------------------------------------------- #

_as_me='get-packument';
_version='0.1.0';


# ---------------------------------------------------------------------------- #

: "${CURL:=curl}";
: "${JQ:=jq}";
: "${DATE:=date}";
: "${MKTEMP:=mktemp}";


# ---------------------------------------------------------------------------- #

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -l|--last-mod*|--lastmod*)
      LAST_MOD="$2";
      shift;
    ;;
    *)
      if [[ -z "${PKG:-}" ]]; then
        PKG="$1";
      else
        echo "$_as_me: Unexpected argument '$*'" >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

PFILE="$( $MKTEMP; )";
PFILE2="$( $MKTEMP; )";

# ---------------------------------------------------------------------------- #

cleanup() {
  rm -f "$PFILE" "$PFILE2";
}

_ec=0;
trap '_ec="$?"; cleanup; exit "$_ec";' HUP INT TERM QUIT;


# ---------------------------------------------------------------------------- #

$CURL -s "https://registry.npmjs.org/$PKG" > "$PFILE";


# ---------------------------------------------------------------------------- #

if [[ -n "${LAST_MOD:-}" ]]; then
  # Desired Format:  2018-04-24T18:07:37.696Z
  # Can be compared "lexicographically" with simple `[[ "${LAST_MOD}" < ... ]]'
  # Example:         date -u +%FT%T.%3NZ;
  LAST_MOD="$( $DATE -u +%FT%T.%3NZ -d "$LAST_MOD"; )";
  cmd='del( .time.modified )';
  for l in $(
    $JQ -r '.time|to_entries|map( .key + "+" + .value )[]' "$PFILE";
  ); do
    if [[ "${l#*+}" = "$LAST_MOD" ]] || [[ "${l#*+}" < "$LAST_MOD" ]]; then
      continue;
    fi
    cmd+="|del( .time[\"${l%+*}\"] )|del( .versions[\"${l%+*}\"] )";
  done
  $JQ "$cmd" "$PFILE" > "$PFILE2";
  mv "$PFILE2" "$PFILE";
fi


# ---------------------------------------------------------------------------- #

$JQ '.
|del( .readme )
|del( .readmeFilename )
|del( .["dist-tags"] )
|del( .users )
|del( .maintainers )
|del( .contributors )
|del( ._rev )
' "$PFILE";

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
