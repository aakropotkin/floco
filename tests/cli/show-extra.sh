#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}";
: "${NIX:=nix}";
: "${JQ:=jq}";

# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";
_as_me="${SPATH##*/}";

# ---------------------------------------------------------------------------- #

narHash="$(
  _e_floco_cfg='{
    floco.pdefs.lodash."4.17.21" = { ident = "lodash"; version = "4.17.21"; };
  }' $NIX run "$SDIR#floco" -- show lodash 4.17.21 --json  \
       |$JQ -r .fetchInfo.narHash;
)";

echo "$_as_me: Expect: sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=" >&2;
echo "$_as_me: Got:    $narHash" >&2;

[[ "$narHash" = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=" ]];


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #

