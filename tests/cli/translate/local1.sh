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

Test the \`floco translate' updater on a local package which requires no
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

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      _i=1;
      while [[ "$_i" -lt "${#_arg}" ]]; do
        _args+=( "-${_arg:$_i:1}" );
        _i="$(( _i + 1 ))";
      done
      set -- "${_args[@]}" "$@";
      unset _arg _args _i;
      continue;
    ;;
    --*=*)
      _arg="$1";
      shift;
      set -- "${_arg%%=*}" "${_arg#*=}" "$@";
      unset _arg;
      continue;
    ;;
    -u|--usage)              usage;    exit 0; ;;
    -h|--help)               usage -f; exit 0; ;;
    -v|--version)            echo "$_version"; exit 0; ;;
    --)                      shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      echo "$_as_me: Unexpected argument(s) '$*'" >&2;
      usage -f >&2;
      exit 1;
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";
PROOT="${SDIR%/tests/cli/translate}";
FLAKE_REF="$PROOT";


# ---------------------------------------------------------------------------- #

declare -a tmp_files tmp_dirs;
tmp_files=();
tmp_dirs=();


# ---------------------------------------------------------------------------- #

cleanup() {
  echo rm -f "${tmp_files[@]}";
  echo rm -rf "${tmp_dirs[@]}";
}

_es=0;
trap '_es="$?"; cleanup; exit "$_es";' HUP TERM INT QUIT EXIT;


# ---------------------------------------------------------------------------- #

OUTDIR="$( $MKTEMP -d; )";
tmp_dirs+=( "$OUTDIR" );
pushd "$OUTDIR" >/dev/null;

echo '
{
  "name": "@floco/phony",
  "version": "4.2.0",
  "dependencies": {
    "pacote": "5.x"
  },
  "devDependencies": {
    "@babel/core": "*"
  },
  "scripts": {
    "build": "touch ./built"
  }
}
' > ./package.json;

$NIX run "$FLAKE_REF" -- translate --json;

TARGET_ENT="$( $MKTEMP; )";
tmp_files+=( "$TARGET_ENT" );
# XXX: This only works when `PKG' is a raw identifier.
$JQ '.floco.pdefs["@floco/phony"]["4.2.0"]' ./pdefs.json > "$TARGET_ENT";


# ---------------------------------------------------------------------------- #

# Checks

echo "Assert that \`treeInfo' is defined:" >&2;
$JQ -e '( .treeInfo // {} ) != {}' "$TARGET_ENT" >&2;

echo "Assert that \`fetchInfo' is defined as a path:" >&2;
$JQ -e '( .fetchInfo // "" )|test( "^path:" )' "$TARGET_ENT" >&2;

echo "Assert that \`lifecycle.build' is \`true':" >&2;
$JQ -e '( .lifecycle // { build: false } ).build' "$TARGET_ENT" >&2;


# ---------------------------------------------------------------------------- #

export FLAKE_REF;
$NIX build --show-trace -f - <<'EOF'
let
  floco   = builtins.getFlake ( builtins.getEnv "FLAKE_REF" );
  inherit (floco) lib;
  mod = lib.evalModules {
    modules = [
      "${floco}/modules/top"
      ( lib.modules.importJSON ./pdefs.json )
      { config.floco.settings.system = builtins.currentSystem; }
    ];
  };
  pkg = mod.config.floco.packages."@floco/phony"."4.2.0";
in pkg.global
EOF


# ---------------------------------------------------------------------------- #

echo "Assert that built products exist in global output:" >&2;
if [[ ! -e ./result/lib/node_modules/@floco/phony/built ]]; then
  echo "false" >&2;
  echo "$_as_me: Failed to produce build products." >&2;
  exit 1;
else
  echo "true" >&2;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
