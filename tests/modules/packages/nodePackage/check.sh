#! /usr/bin/env bash
: "${NIX:=nix}";
SPATH="${BASH_SOURCE[0]}";
SDIR="${SPATH%/*}";

NVERSION="$( $NIX shell -f "$SDIR/default.nix" -c test; )";
case "$NVERSION" in
  v16.*) exit 0; ;;
  *)     exit 1; ;;
esac
