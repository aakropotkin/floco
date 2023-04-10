#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="${BASH_SOURCE[0]##*/}";

_version="0.1.0";

_usage_msg="$_as_me [OPTIONS...]

Test the \`floco translate' updater on registry a package which requires no
\`node-gyp' installs and uses only \`npm' registry dependencies.
";

_help_msg="$_usage_msg

OPTIONS
  -h,--help         Print help message to STDOUT.
  -u,--usage        Print usage message to STDOUT.
  -v,--version      Print version information to STDOUT.

ENVIRONMENT
  NIX               Command used as \`nix' executable.
  JQ                Command used as \`jq' executable.
  NPM               Command used as \`npm' executable.
  REALPATH          Command used as \`realpath' executable.
  MKTEMP            Command used as \`mktemp' executable.
";


# ---------------------------------------------------------------------------- #

usage() {
  if [[ "${1:-}" = "-f" ]]; then
    echo "$_help_msg";
  else
    echo "$_usage_msg";
  fi
}


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${NIX:=nix}";
: "${NPM:=npm}";
: "${JQ:=jq}";
: "${REALPATH:=realpath}";
: "${MKTEMP:=mktemp}";


# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";
PROOT="${SDIR%/tests/cli/translate}";
FLAKE_REF="$PROOT";


# ---------------------------------------------------------------------------- #

declare -a tmp_files tmp_dirs;
tmp_files=();
tmp_dirs=();

mktmp_auto() {
  local _f;
  _f="$( $MKTEMP "$@"; )";
  case " $* " in
    *\ -d\ *|*\ --directory\ *) tmp_dirs+=( "$_f" ); ;;
    *)                          tmp_files+=( "$_f" ); ;;
  esac
  echo "$_f";
}


# ---------------------------------------------------------------------------- #

cleanup() {
  rm -f "${tmp_files[@]}";
  rm -rf "${tmp_dirs[@]}";
}

_es=0;
trap '_es="$?"; cleanup; exit "$_es";' HUP TERM INT QUIT EXIT;


# ---------------------------------------------------------------------------- #

OUTDIR="$( mktmp_auto -d; )";
cp -p --reflink=auto -- "$SDIR/"{floco-cfg,foverrides,pdefs}.nix "$OUTDIR/";
cp -p --reflink=auto -- "$SDIR/package-2.json" "$OUTDIR/package.json";
pushd "$OUTDIR" >/dev/null;

$NIX run "$FLAKE_REF" -- translate;

TARGET_ENT="$( mktmp_auto; )";
$NIX eval --json -f ./pdefs.nix                                               \
          --apply 'x: x.floco.pdefs."@floco/phony"."4.2.0"' > "$TARGET_ENT";


# ---------------------------------------------------------------------------- #

# Checks

echo "Assert that \`pacote' is defined as a dependency:" >&2;
$JQ -e '( .depInfo // {} ).pacote != null' "$TARGET_ENT" >&2;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
