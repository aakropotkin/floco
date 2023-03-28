#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="nix-args-wrap.sh";

_version="0.1.0";

_usage_msg="USAGE: $_as_me [OPTIONS...]
Fix \`nix eval -f FILE --arg foo 1 --argstr bar howdy;' arg handling
";

_help_msg="$_usage_msg
OPTIONS
  -h,--help         Print help message to STDOUT.
  -u,--usage        Print usage message to STDOUT.
  -v,--version      Print version information to STDOUT.

ENVIRONMENT
  NIX               Command used as \`nix' executable.
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


# ---------------------------------------------------------------------------- #

declare -a nixArgs=();
declare -A nixVars=();


# ---------------------------------------------------------------------------- #

if [[ "${1:-}" = eval ]]; then
  shift;
fi

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

    --apply)
      echo "$_as_me: \`--apply' may not be used with this wrapper" >&2;
      exit 1;
    ;;

    --arg|--argstr)
      if [[ "$#" -lt 3 ]]; then
        echo "$_as_me: \`$1' used with insufficient arguments: '$*'" >&2;
        usage -f >&2;
        exit 1;
      fi
      if [[ "$1" = '--arg' ]]; then
        nixVars["$2"]="$3";
      else
        nixVars["$2"]="\"$3\"";
      fi
      shift 2;
    ;;

    --)
      shift;
      nixArgs+=( "$@" );
      break;
    ;;

    *) nixArgs+=( "$1" ); ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

app="f: f {";
for name in "${!nixVars[@]}"; do
  eval val="\${nixVars[$name]}";
  app="$app $name = $val;";
done
app="$app }";


# ---------------------------------------------------------------------------- #

exec $NIX eval "${nixArgs[@]}" --apply "$app";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
