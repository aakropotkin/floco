#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;

# ---------------------------------------------------------------------------- #

_as_main='floco';
_as_sub='download';
_as_me="$_as_main $_as_sub";

_version='0.1.0';

_usage_msg="Usage: $_as_me [OPTIONS...] IDENT[@DESCRIPTOR]

Download and extract an NPM package/module using a package specifier.
";

_help_msg="$_usage_msg



Options:
  -o,--out-dir PATH   Extract package to given directory instead of \`package/'.
  -l,--link           Symlink extracted package from read-only store.
  -L,--no-link        Copy extracted package from read-only store.

Environment:
  NIX           Command used as \`nix' executable.
  FLOCO         Command used as \`floco' executable.
  JQ            Command used as \`jq' executable.
  REALPATH      Command used as \`realpath' executable.
  MKDIR         Command used as \`mkdir' executable.
  CP            Command used as \`cp' executable.
  LN            Command used as \`ln' executable.
  CHMOD         Command used as \`chmod' executable.
  FLAKE_REF     Flake URI ref to use for \`floco'.
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

: "${FLAKE_REF:=github:aakropotkin/floco}";
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

# @BEGIN_INJECT_UTILS@
: "${NIX:=nix}";
: "${FLOCO:=$NIX run "$FLAKE_REF#floco --"}";
: "${JQ:=jq}";
: "${REALPATH:=realpath}";
: "${MKDIR:=mkdir}";
: "${CP:=cp}";
: "${LN:=ln}";
: "${CHMOD:=chmod}";


# ---------------------------------------------------------------------------- #

unset OUTDIR PKG;

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
    -o|--out-dir|--outdir) OUTDIR="$( $REALPATH "$2"; )"; shift; ;;
    -l,--link)             LINK=:; ;;
    -L,--no-link|--nolink) LINK=; ;;
    -u|--usage)            usage;    exit 0; ;;
    -h|--help)             usage -f; exit 0; ;;
    -v|--version)          echo "$_version"; exit 0; ;;
    --)                    shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      if [[ -z "${PKG:-}" ]]; then
        PKG="$1";
      else
        echo "$_as_me: Unexpected argument(s) '$*'" >&2;
        usage -f >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done

: "${OUTDIR:=$PWD/package}";


# ---------------------------------------------------------------------------- #

if [[ -e "$OUTDIR" ]]; then
  echo "$_as_me: Output path \`$OUTDIR' already exists. Giving up." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

export PKG;

dlmod() {
  $FLOCO eval --impure --raw --expr '( builtins.fetchTree {
    type = "tarball";
    url  = let
      res = builtins.npmResolve ( builtins.getEnv "PKG" );
      m   = builtins.match ".*\n([^\n]+)\n?" res;
    in if m == null then res else builtins.head m;
  } ).outPath';
}


# ---------------------------------------------------------------------------- #

if [[ -z "${LINK:-}" ]]; then
  $MKDIR -p "$OUTDIR";
  $CP -r --no-preserve=owner -T -- "$( dlmod; )" "$OUTDIR";
  $CHMOD -R +w "$OUTDIR";
else
  $MKDIR -; "${OUTDIR%/*}";
  $LN -s -T -- "$( dlmod; )" "$OUTDIR";
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
