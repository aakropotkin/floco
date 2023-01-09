#! /usr/bin/env bash
set -eu;
set -o pipefail;
: "${NIX:=nix}";
: "${JQ:=jq}";
: "${TAR:=tar}";
: "${REALPATH:=realpath}";
SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";

outpath="$( nix build -f "$SDIR" --no-link --print-out-paths "$@"; )";
manifest="$( $TAR tzf "$outpath"; )";

while read -r line; do
  case "$line" in
    package/foo|package/package.json) :; ;;
    *) echo "Unexpected file: $line" >&2; exit 1; ;;
  esac
done <<<"$manifest"

case "$manifest" in
  *package/foo*) :; ;;
  *) echo "Failed to package built file: foo" >&2; exit 1; ;;
esac
case "$manifest" in
  *package/package.json*) :; ;;
  *) echo "Failed to package file: package.json" >&2; exit 1; ;;
esac

exit 0;
