#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;

# ---------------------------------------------------------------------------- #

_as_me='get-packument';

_version='0.1.0';

_usage_msg="$_as_me [OPTIONS...] [-l DATE] IDENT

Fetch a packument from \`https://registry.npmjs.org' for a given package and
print the package's abbreviated version info ( manifests ) and
creation/modification times.

The option \`--last-mod DATE' accepts any date/time string recognized by the
UNIX \`date' command, accurate to miliseconds, and is treated as \"inclusive\".
";

_help_msg="$_usage_msg

OPTIONS
  -l,--last-mod DATE  Omit versions created after \`DATE'.
  -h,--help           Print help message to STDOUT.
  -u,--usage          Print usage message to STDOUT.
  -v,--version        Print version information to STDOUT.

ENVIRONMENT
  CURL                Command used as \`curl' executable.
  JQ                  Command used as \`jq' executable.
  DATE                Command used as \`date' executable.
  MKTEMP              Command used as \`mktemp' executable.
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
: "${CURL:=curl}";
: "${JQ:=jq}";
: "${DATE:=date}";
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
    -l|--last-mod*|--lastmod*) LAST_MOD="$2"; shift; ;;
    -u|--usage)                usage;    exit 0; ;;
    -h|--help)                 usage -f; exit 0; ;;
    -v|--version)              echo "$_version"; exit 0; ;;
    --)                        shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      if [[ -z "${PKG:-}" ]]; then
        PKG="$1";
      else
        echo "$_as_me: Unexpected argument '$*'" >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done


if [[ -z "${PKG:-}" ]]; then
  echo "$_as_me: You must provide a package name" >&2;
  echo '' >&2;
  usage >&2;
  exit 1;
fi


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

PFILE="$( mktmp_auto; )";
PFILE2="$( mktmp_auto )";


# ---------------------------------------------------------------------------- #

$CURL -s "https://registry.npmjs.org/$PKG" > "$PFILE";


# ---------------------------------------------------------------------------- #

if [[ -n "${LAST_MOD:-}" ]]; then
  # Desired Format:  2018-04-24T18:07:37.696Z
  # Can be compared "lexicographically" with simple `[[ "${LAST_MOD}" < ... ]]'
  # Example:         date -u +%FT%T.%3NZ;
  LAST_MOD="$( $DATE -u +%FT%T.%3NZ -d "$LAST_MOD"; )";
  cmd='del( .time.modified )';
  for l in $(
    $JQ -r '.time|to_entries|map( .key + "+" + .value )[]' "$PFILE";
  ); do
    if [[ "${l#*+}" = "$LAST_MOD" ]] || [[ "${l#*+}" < "$LAST_MOD" ]]; then
      continue;
    fi
    cmd+="|del( .time[\"${l%+*}\"] )|del( .versions[\"${l%+*}\"] )";
  done
  $JQ "$cmd" "$PFILE" > "$PFILE2";
  mv "$PFILE2" "$PFILE";
fi


# ---------------------------------------------------------------------------- #

$JQ '{ versions: .versions, time: .time, _id: ._id }' "$PFILE";

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
