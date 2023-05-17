#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="fidb.sh";

_version="0.1.0";

_usage_msg="USAGE: $_as_me [OPTIONS...] DB-PATH CMD [ARGS...]
Interact with a \`fetch-info.db'.
";

_help_msg="$_usage_msg
COMMANDS
  init              Initialize a new database.
  add URL           Generate and fill rows associated with URL.
  set URL           Set rows associated with URL.
  get URL           Get rows associated with URL.
  delete URL        Delete rows associated with URL.
  run SQL-CMD...    Run raw SQL command(s) on database.

OPTIONS
  -h,--help         Print help message to STDOUT.
  -u,--usage        Print usage message to STDOUT.
  -v,--version      Print version information to STDOUT.

ENVIRONMENT
  GREP              Command used as \`grep' executable.
  REALPATH          Command used as \`realpath' executable.
  MKTEMP            Command used as \`mktemp' executable.
  SQLITE            Command used as \`sqlite3' executable.
  JQ                Command used as \`jq' executable.
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
: "${SQLITE:=sqlite3}";
: "${JQ:=jq}";


# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";


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

unset _db _cmd _url;
declare -a _sql_cmds;
_sql_cmds=();

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
      echo '' >&2;
      usage -f >&2;
      exit 1;
    ;;
    init)   _cmd='init'; ;;
    add)    _cmd='add';    shift; _url="$1"; ;;
    get)    _cmd='get';    shift; _url="$1"; ;;
    delete) _cmd='delete'; shift; _url="$1"; ;;
    run)    _cmd='run'; ;;
    set)
      _cmd='set';
      shift;
      _url="$1";
    ;;
    *)
      if [[ -z "${_db:-}" ]]; then
        _db="$( $REALPATH "$1"; )";
      elif [[ "${_cmd:-}" = run ]]; then
        _sql_cmds+=( "$1" );
      else
        echo "$_as_me: Unexpected argument(s) '$*'" >&2;
        echo '' >&2;
        usage -f >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

if [[ -z "${_cmd:-}" ]]; then
  echo "$_as_me: You must indicate a sub-command" >&2;
  echo '' >&2;
  usage -f >&2;
  exit 1;
fi

if [[ -z "${_db:-}" ]]; then
  echo "$_as_me: You must indicate a database" >&2;
  echo '' >&2;
  usage -f >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

fi_init() {
  if ! [[ -e "$_db" ]]; then
    $SQLITE "$_db" < "$SDIR/fetch-info.sql";
  elif ! [[ -w "$_db" ]]; then
    echo "$_as_me: Cannot write to database: '$_db'" >&2;
    echo '' >&2;
    usage -f >&2;
    exit 1;
  fi
}


# ---------------------------------------------------------------------------- #

fi_run() {
  fi_init;
  $SQLITE "$_db" "${_sql_cmds[@]}";
}


# ---------------------------------------------------------------------------- #

fi_get() {
  if [[ -z "${_url:-}" ]]; then
    echo "$_as_me: You must indicate a url" >&2;
    echo '' >&2;
    usage -f >&2;
    exit 1;
  fi
  fi_run "SELECT * FROM v_TarballsJSON WHERE url = \"$_url\"";
}


# ---------------------------------------------------------------------------- #

case "$_cmd" in
  init) fi_init; ;;
  run)  fi_run; ;;
  get)  fi_get; ;;
  #set)    fi_set; ;;
  #delete) fi_delete; ;;
  #add)    fi_add; ;;
  *) :; ;;  # Unreachable
esac


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
