#! /usr/bin/env bash
set -eu;
: "${NIX:=nix}";
: "${REALPATH:=realpath}";
SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";
$NIX eval --impure -f "$SDIR/lodash.nix" --json --apply 'f: f {}';
