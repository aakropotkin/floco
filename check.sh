#! /usr/bin/env bash
# ============================================================================ #
#
# Runs subtests in a top-level harness.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail

# ---------------------------------------------------------------------------- #

_as_me='check.sh';


# ---------------------------------------------------------------------------- #

_es=0;
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

trap '
_es="$?";
echo "$_as_me: Run Cancelled" >&2;
exit "$_es";
' HUP TERM INT QUIT;


# ---------------------------------------------------------------------------- #

: "${NIX:=nix}";
: "${REALPATH:=realpath}"
: "${SHELLCHECK:=$NIX run 'nixpkgs#shellcheck' --}";

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";


# ---------------------------------------------------------------------------- #

run_test "Packages Module"        "$SDIR/tests/modules/packages/check.sh";
run_test "Packages Module (dist)" "$SDIR/tests/modules/packages/dist/check.sh";

run_test "Library Extensions" "$SDIR/tests/lib/check.sh";

run_test "pdef (deserialized)"                                    \
  $NIX eval --show-trace -f "$SDIR/tests/modules/pdef/deserial";

run_test "pdef lodash registry"                                      \
  $NIX eval --json -f "$SDIR/tests/modules/pdef/from-registry.nix";

run_test "install-module lodash"                   \
  $NIX build --no-link --show-trace                \
       -f "$SDIR/tests/setup/lodash-install.nix";

run_test "run-script trivial"                                               \
  $NIX build --no-link --show-trace -f "$SDIR/tests/setup/run-script.nix";

run_test "updaters: from-registry pacote"                \
         "$SDIR/tests/updaters/from-registry/proj1.sh";

run_test "updaters: npm-plock proj1" "$SDIR/tests/updaters/npm-plock/proj1.sh";

run_test "treeInfo from pins"                                                \
  test "$( $NIX eval -f "$SDIR/tests/modules/pdefs/pinned" ok; )" = 'true';

run_test "linkedLocks"                                                       \
  $NIX eval --json -f "$SDIR/tests/modules/plock/linked-locks" linkedLocks;

run_test "target override/extras"                                       \
  $NIX build -L --no-link -f "$SDIR/tests/modules/packages/overrides";

run_test "shellcheck"                                           \
  "$SHELLCHECK" -x "$SDIR/"{updaters,pkgs/cli/src/{,*/}}/*.sh;

run_test "nix flake check" $NIX flake check "$SDIR";


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
