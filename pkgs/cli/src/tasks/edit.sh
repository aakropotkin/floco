#! /usr/bin/env bash
# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# Edit a trivial `*.nix' file, rewriting its contents, maybe applying
# an expression.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${_as_main=floco}";
_as_sub='edit';
_as_me="$_as_main $_as_sub";

: "${_version:=0.1.1}";

_usage_msg="\
Usage: $_as_me [OPTIONS]... [{-i|--in-place}] [{-a|--apply} EXPR] FILE

Modify and rewrite a trivial Nix file.
";

_help_msg="$_usage_msg
FILE must be a trivial Nix file, i.e. an expression that evaluates to an
attribute set, number, string, list, boolen, or null - NOT a function.

If no \`--apply' option is given, the file is rewritten in its \"flat\"
evaluated form.

OPTIONS
  -i,--in-place     Edit the file in-place, overwriting it.
  -a,--apply EXPR   Apply EXPR to the file's contents.
  -h,--help         Print help message to STDOUT.
  -u,--usage        Print usage message to STDOUT.
  -v,--version      Print version information to STDOUT.

ENVIRONMENT
  GREP              Command used as \`grep' executable.
  HEAD              Command used as \`head' executable.
  JQ                Command used as \`jq' executable.
  MKTEMP            Command used as \`mktemp' executable.
  NIX               Command used as \`nix' executable.
  REALPATH          Command used as \`realpath' executable.
  XDG_CONFIG_HOME   Used to find \`XDG_CONFIG_HOME/floco/floco-cfg.{nix,json}'.
  _g_floco_cfg      Path to global floco config file. May be set to \`null'.
  _u_floco_cfg      Path to user floco config file. May be set to \`null'.
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
: "${GREP:=grep}";
: "${REALPATH:=realpath}";
: "${MKTEMP:=mktemp}";
: "${NIX:=nix}";
: "${JQ:=jq}";
: "${HEAD:=head}";
export GREP REALPATH MKTEMP NIX JQ HEAD;


# ---------------------------------------------------------------------------- #

unset _EXPR _FILE _IN_PLACE;

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
    -a|--apply)    _EXPR="$2"; shift; ;;
    -i|--in-place) _IN_PLACE=:; ;;
    --) shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      if [[ -z "${_FILE:-}" ]]; then
        _FILE="$1";
      else
        echo "$_as_me: Unexpected argument(s) '$*'" >&2;
        printf '\n' >&2;
        usage -f >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done

: "${_EXPR:=x: x}";
: "${_IN_PLACE=}";

if [[ -z "${_FILE:-}" ]]; then
  echo "$_as_me: Missing argument \`FILE'." >&2;
  printf '\n' >&2;
  usage >&2;
  exit 1;
fi

if ! [[ -r "$_FILE" ]]; then
  echo "$_as_me: Cannot read file \`$_FILE'." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

case "$( $NIX eval --raw -f "$_FILE" --apply builtins.typeOf; )" in
  set|bool|function|int|list|null|string)
    :;
  ;;
  *)
    echo "$_as_me: \`$_FILE' is not a trivial Nix file." >&2;
    exit 1;
  ;;
esac


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}/../lib"; )}";
: "${FLOCO_NIX_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}/../nix/lib"; )}";
export FLOCO_LIBDIR FLOCO_NIX_LIBDIR;


# ---------------------------------------------------------------------------- #

# Load common helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../lib/common.sh
. "$FLOCO_LIBDIR/common.sh";


# ---------------------------------------------------------------------------- #

runEval() {
  $NIX eval --raw -f "$_FILE" --apply "f: let
    inherit (builtins.getFlake \"$( flocoRef; )\") lib;
    blib = if lib ? prettyPrintEscaped then lib else lib // {
      libfloco = lib.libfloco //
        ( import $FLOCO_NIX_LIBDIR/util.nix { inherit lib; } );
    };
    r = ( $_EXPR ) f;
    p = blib.libfloco.prettyPrintEscaped r;
  in assert ! ( builtins.isFunction r ); p";
}


if [[ -n "$_IN_PLACE" ]]; then
  #shellcheck disable=SC2119
  _TFILE="$( mktmpAuto; )";
  runEval > "$_TFILE";
  mv "$_FILE" "$_FILE~";
  mv "$_TFILE" "$_FILE";
  echo "$_as_me: Rewrote file \`$_FILE' with backup \`$_FILE~'." >&2;
else
  runEval;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
