#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

: "${NIX:=nix}";
: "${JQ:=jq}";


# ---------------------------------------------------------------------------- #

SPATH="${BASH_SOURCE[0]}";
SDIR="${SPATH%/*}";


# ---------------------------------------------------------------------------- #

TVERSION="$( $NIX shell -f "$SDIR/default.nix" -c test; )";
case "$TVERSION" in
  v16.*) :; ;;
  *)
    echo "fail: Expected version 16.x but executable has '$TVERSION'" >&2;
    exit 1;
  ;;
esac


# ---------------------------------------------------------------------------- #

mapfile -t DRV_NODE_VERSIONS < <(
  $NIX path-info -r --json "$(
    $NIX build --no-link --print-out-paths -f "$SDIR/default.nix";
  )"|$JQ -r 'map( .path|select( test( "-nodejs-" ) )
               |capture( ".*-nodejs-(?<version>.*)" )
               |.version
             )[]';
);

# ---------------------------------------------------------------------------- #

case "${#DRV_NODE_VERSIONS[@]}" in
  0)
    echo "fail: Expected a single node reference in closure, but none" >&2;
    exit 2;
  ;;
  1) :; ;;
  *)
    echo "fail: Expected a single node reference in closure, but got:" >&2;
    printf "  '%s'\n" "${DRV_NODE_VERSIONS[@]}" >&2;
    exit 3;
  ;;
esac


# ---------------------------------------------------------------------------- #

case "${DRV_NODE_VERSIONS[0]}" in
  16.*) :; ;;
  *)
    printf 'fail: Expected version 16.x but derivation references ' >&2;
    echo "'${DRV_NODE_VERSIONS[0]}'" >&2;
    exit 4;
  ;;
esac


# ---------------------------------------------------------------------------- #

exit 0;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
