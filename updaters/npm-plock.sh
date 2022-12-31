#! /usr/bin/env bash
# ============================================================================ #
#
# Update a `pdefs.nix' file using a `package-lock.json' v3 provided by `npm'.
#
# This script will trash any existing `node_modules/' trees, and if a
# `package-lock.json' file already exists, it will be updated to use the v3
# schema as a side effect of this script.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="floco update npm-plock";

_version="0.1.0";

_usage_msg="$_as_me [-l LOCK-DIR] [-o PDEFS-FILE] [-c FLOCO-CONFIG-FILE]

Update a \`pdefs.nix' file using a \`package-lock.json' v3 provided by \`npm'.
";

_help_msg="$_usage_msg

This script will trash any existing \`node_modules/' trees, and if a
\`package-lock.json' file already exists, it will be updated to use the v3
schema as a side effect of this script.

OPTIONS
  -l,--lock-dir PATH  Path to directory containing \`package[-lock].json'.
                      This directory must contain a \`package.json', but need
                      not
                      contain a \`package-lock.json'.
                      Defaults to current working directory.
  -o,--out-file PATH  Path to write generated \`pdef' records.
                      Defaults to \`<LOCK-DIR>/pdefs.nix'.
                      If the outfile already exists, it may be used to optimize
                      translation, and will be backed up to \`PDEFS-FILE~'.
  -c,--config PATH    Path to a \`floco' configuration file which may be used to
                      extend or modify the module definitions used to translate
                      and export \`pdef' records.
                      If no config is given default settings will be used.

ENVIRONMENT
  NIX           path to \`nix' executable.
  NPM           path to \`npm' executable.
  JQ            path to \`jq' executable.
  REALPATH      path to \`realpath' executable.
  FLOCO_CONFIG  path to a \`floco' configuration file. Used as \`--config'.
  FLOCO_REF     flake URI ref to use for \`floco'.
                defaults to \`github:aakropotkin/floco'.
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


# ---------------------------------------------------------------------------- #

unset OUTFILE LOCKDIR;

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      while read -r -n1 opt; do
        if [[ -z "$opt" ]]; then
          break;
        fi
        _args+=( "-$opt" );
      done <<<"${_arg#-}";
      set -- "${_args[@]}" "$@";
      unset _arg _args;
      continue;
    ;;
    --*=*)
      _arg="$1";
      shift;
      set -- "${_arg%=*}" "${_arg#*=}" "$@";
      unset _arg;
      continue;
    ;;
    -l|--lock-dir) LOCKDIR="$( $REALPATH "$2"; )"; shift; ;;
    -o|--out-file) OUTFILE="$( $REALPATH "$2"; )"; shift; ;;
    -c|--config)   FLOCO_CONFIG="$2"; shift; ;;
    -u|--usage)    usage;    exit 0; ;;
    -h|--help)     usage -f; exit 0; ;;
    -v|--version)  echo "$_version"; exit 0; ;;
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

if [[ -n "${FLOCO_CONFIG:-}" ]]; then
  FLOCO_CONFIG="$( $REALPATH "$FLOCO_CONFIG"; )";
fi
: "${LOCKDIR:=$PWD}";
: "${OUTFILE:=$LOCKDIR/pdefs.nix}";
: "${FLAKE_REF:=github:aakropotkin/floco}";


# ---------------------------------------------------------------------------- #

# Make relative flake ref absolute
case "$FLAKE_REF" in
  *:*) :; ;;
  .*|/*) FLAKE_REF="$( $REALPATH "$FLAKE_REF"; )"; ;;
  *)
    if [[ -r "$FLAKE_REF/flake.nix" ]]; then
      FLAKE_REF="$( $REALPATH "$FLAKE_REF"; )";
    fi
  ;;
esac


# ---------------------------------------------------------------------------- #

# Lint target package for stuff that will trip up attempts to generate `pdefs'.
if [[ "$( $JQ -r '.name // null' "$LOCKDIR/package.json"; )" = 'null' ]]; then
  echo "$_as_me: target package is unnamed. name it you dingus." >&2;
  exit 1;
fi

if [[ "$( $JQ -r '.version // null' "$LOCKDIR/package.json"; )" = 'null' ]];
then
  echo "$_as_me: target package is unversioned. version it you dangus." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

# Backup existing outfile if one exists
if [[ -r "$OUTFILE" ]]; then
  echo "$_as_me: backing up existing \`pdefs.nix' to \`$OUTFILE~'" >&2;
  cp -p -- "$OUTFILE" "$OUTFILE~";
fi

# Backup existing lockfile if one exists
if [[ -r "$LOCKDIR/package-lock.json" ]]; then
  printf '%s' "$_as_me: backup up existing \`package-lock.json' to "  \
              "\`$LOCKDIR/package-lock.json~'" >&2;
  echo '' >&2;
  cp -p -- "$LOCKDIR/package-lock.json" "$LOCKDIR/package-lock.json~";
fi


# ---------------------------------------------------------------------------- #

if [[ -d "$LOCKDIR/node_modules" ]]; then
  echo "$_as_me: deleting \`$LOCKDIR/node_modules' to avoid pollution" >&2;
  rm -rf "$LOCKDIR/node_modules";
fi


# ---------------------------------------------------------------------------- #

pushd "$LOCKDIR" >/dev/null;
$NPM install            \
  --package-lock-only   \
  --ignore-scripts      \
  --lockfile-version=3  \
  --no-audit            \
  --no-funding          \
  --no-color            \
;


# ---------------------------------------------------------------------------- #

cleanup() {
  rm -f "$OUTFILE";
}
trap '_es="$?"; cleanup; exit "$_es";' HUP TERM INT QUIT;


# ---------------------------------------------------------------------------- #

# TODO: flake ref or something.
# TODO: unstringize `fetchInfo' relative paths.
$NIX --no-substitute eval --impure --raw -f - <<'EOF' >"$OUTFILE"
let
  floco = builtins.getFlake ( builtins.getEnv "FLAKE_REF" );
  inherit (floco.inputs.nixpkgs) lib;
  # TODO: use `old' and `cfg' as modules.
  #cfgPath = builtins.getEnv "FLOCO_CONFIG";
  #cfg     = if ( cfgPath != "" ) && ( builtins.pathExists cfgPath )
  #          then [cfgPath]
  #          else [];
  #outfile = builtins.getEnv "OUTFILE";
  #oldfile = if ( outfile == "" ) then null else outfile + "~";
  #old     = if ( outfile != "" ) && ( builtins.pathExists oldfile )
  #          then [oldfile]
  #          else [];
  pl2pdefs = import "${floco}/modules/plockToPdefs/implementation.nix" {
    inherit lib;
    lockDir = toString ./.;
    plock   = lib.importJSON ./package-lock.json;
  };
  pdefs = map ( v: v._export ) pl2pdefs.packages;
in lib.generators.toPretty {} pdefs
EOF


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
