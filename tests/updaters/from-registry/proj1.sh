#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

PKG="pacote";


# ---------------------------------------------------------------------------- #

_as_me="proj1.sh";

_version="0.1.0";

_usage_msg="$_as_me [OPTIONS...]

Test the \`from-registry.sh' updater on a package which requires no \`node-gyp'
installs and uses only \`npm' registry dependencies.
";

_help_msg="$_usage_msg

Target package is $PKG.

OPTIONS
  -h,--help         Print help message to STDOUT.
  -u,--usage        Print usage message to STDOUT.
  -v,--version      Print version information to STDOUT.

ENVIRONMENT
  NIX               Command used as \`nix' executable.
  JQ                Command used as \`jq' executable.
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
: "${JQ:=jq}";
: "${REALPATH:=realpath}";
: "${MKTEMP:=mktemp}";


# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";
PROOT="${SDIR%/tests/updaters/from-registry}";
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
    -u|--usage)    usage;    exit 0; ;;
    -h|--help)     usage -f; exit 0; ;;
    -v|--version)  echo "$_version"; exit 0; ;;
    --) shift; break; ;;
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

OUTFILE="$( mktmp_auto --suffix=.json; )";
rm -f "$OUTFILE";
$NIX run "$FLAKE_REF#fromRegistry" -- "$PKG" --json -t --out-file "$OUTFILE";

TARGET_ENT="$( mktmp_auto; )";
# XXX: This only works when `PKG' is a raw identifier.
$JQ ".floco.pdefs[\"$PKG\"]|to_entries|.[0].value" "$OUTFILE" > "$TARGET_ENT";


# ---------------------------------------------------------------------------- #

# Checks

echo "Assert that \`treeInfo' is defined:" >&2;
$JQ -e '( .treeInfo // {} ) != {}' "$TARGET_ENT" >&2;

echo "Assert that \`fetchInfo' is defined as an \`npm' tarball:" >&2;
$JQ -e '
if ( .fetchInfo|type ) == "string" then
  ( ( .fetchInfo // "" ) |test( "^tarball\\+https://registry\\.npmjs\\.org" ) )
else
  ( ( .fetchInfo // {} )
    |( ( ( .type // "" ) == "tarball" ) and
       ( ( .url // "" )|test( "^https://registry.npmjs.org" ) ) ) )
end
' "$TARGET_ENT" >&2;


# ---------------------------------------------------------------------------- #

TARGET_NAME="$PKG";
TARGET_VERSION="$( $JQ -r '.version' "$TARGET_ENT"; )";
export OUTFILE TARGET_NAME TARGET_VERSION FLAKE_REF;
$NIX build --show-trace --no-link -f - <<'EOF'
let
  floco = builtins.getFlake ( builtins.getEnv "FLAKE_REF" );
  inherit (floco) lib;
  mod = lib.evalModules {
    modules = [
      floco.nixosModules.default
      ( lib.modules.importJSON ( builtins.getEnv "OUTFILE" ) )
    ];
  };
  ident   = builtins.getEnv "TARGET_NAME";
  version = builtins.getEnv "TARGET_VERSION";
  pkg = mod.config.floco.packages.${ident}.${version}.global;
in pkg
EOF


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
