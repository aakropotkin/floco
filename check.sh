#! /usr/bin/env bash
# ============================================================================ #
#
# Runs subtests in a top-level harness.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail

# ---------------------------------------------------------------------------- #

_ec=0;
count=0;

run_test() {
  local name;
  name="$1";
  shift;
  echo "Running Check: $name" >&2;
  if eval "$*" >&2; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"
    _ec=$(( _ec + 1 ));
  fi
  echo '' >&2;
  count=$(( count + 1 ));
}


# ---------------------------------------------------------------------------- #

: "${NIX:=nix}";
: "${REALPATH:=realpath}"

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";


# ---------------------------------------------------------------------------- #

run_test "Packages Module" "$SDIR/tests/modules/packages/check.sh";

run_test "Pdef lodash registry"                                      \
  $NIX eval --json -f "$SDIR/tests/modules/pdef/from-registry.nix";

run_test "install-module lodash"                   \
  $NIX build --no-link --show-trace                \
       -f "$SDIR/tests/setup/lodash-install.nix";

run_test "run-script trivial"                  \
  $NIX build --no-link --show-trace            \
       -f "$SDIR/tests/setup/run-script.nix";


# ---------------------------------------------------------------------------- #

if [[ "$_ec" -gt 0 ]]; then
  echo "FAILED: $_ec/$count checks.";
else
  echo "PASSED: $count/$count checks.";
fi

exit "$_ec";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
