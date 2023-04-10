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
pushd "$OUTDIR" >/dev/null;

$NIX run "$FLAKE_REF" -- translate --json pacote@13.3.0;

TARGET_ENT="$( mktmp_auto; )";
# XXX: This only works when `PKG' is a raw identifier.
$JQ '.floco.pdefs["pacote"]["13.3.0"]' ./pdefs.json > "$TARGET_ENT";


# ---------------------------------------------------------------------------- #

# Checks

echo "Assert that \`treeInfo' is defined:" >&2;
$JQ -e '( .treeInfo // {} ) != {}' "$TARGET_ENT" >&2;

echo "Assert that \`fetchInfo' is defined as a tarball:" >&2;
$JQ -e '( .fetchInfo // {} ).type|. == "tarball"' "$TARGET_ENT" >&2;

echo "Assert that \`ltype' is \`file':" >&2;
$JQ -e '( .ltype // { ltype: null } ) == "file"' "$TARGET_ENT" >&2;


# ---------------------------------------------------------------------------- #

export FLAKE_REF;
$NIX build --show-trace -f - <<'EOF'
let
  floco   = builtins.getFlake ( builtins.getEnv "FLAKE_REF" );
  pkgsFor = floco.inputs.nixpkgs.legacyPackages.${builtins.currentSystem}.extend
              floco.overlays.default;
  inherit (floco) lib;
  mod = lib.evalModules {
    modules = [
      "${floco}/modules/top"
      ( lib.modules.importJSON ./pdefs.json )
      { _module.args.pkgs = pkgsFor; }
    ];
  };
  pkg = mod.config.floco.packages."pacote"."13.3.0";
in pkg.global
EOF


# ---------------------------------------------------------------------------- #

echo "Assert that bin is runnable in global output:" >&2;
if ! ./result/lib/node_modules/.bin/pacote --help >/dev/null 2>&1; then
  echo "$_as_me: Failed to run \`pacote' executable." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
