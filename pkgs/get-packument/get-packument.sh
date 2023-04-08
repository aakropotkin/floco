#! /usr/bin/env bash
# ============================================================================ #
#
#
#
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
    -b|--before)
      BEFORE="$2";
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

if [[ -n "${BEFORE:-}" ]]; then
  # Desired Format:  2018-04-24T18:07:37.696Z
  # Can be compared "lexicographically" with simple `[[ "${BEFORE}" < ... ]]'
  # Example:         date -u +%FT%T.%3NZ;
  BEFORE="$( $DATE -u +%FT%T.%3NZ -d "$BEFORE"; )";
fi


# ---------------------------------------------------------------------------- #

PFILE="$( $MKTEMP; )";


# ---------------------------------------------------------------------------- #

cleanup() {
  rm -f "$PFILE";
}

_ec=0;
trap '_ec="$?"; cleanup; exit "$_ec";' HUP INT TERM QUIT;


# ---------------------------------------------------------------------------- #

$CURL -s "https://registry.npmjs.org/$PKG" > "$PFILE";


# ---------------------------------------------------------------------------- #

declare -a versions;
versions=();

for l in $(
  $JQ -r '.time|to_entries|map( .key + "+" + .value )[]' "$PFILE";
); do
  if [[ -n "${BEFORE:-}" ]]; then
    if [[ "$BEFORE" < "${l#*+}" ]]; then
      continue;
    fi
  fi
  versions+=( "${l%+*}" );
done


# ---------------------------------------------------------------------------- #

printf '%s\n' "${versions[@]}";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
