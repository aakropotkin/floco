#! /usr/bin/env bash
# ============================================================================ #
#
# List all known packages declared in a given directory.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${_as_main=floco}";
_as_sub='show';
_as_me="$_as_main $_as_sub";

: "${_version:=0.1.0}";

_usage_msg="Usage: $_as_me [OPTIONS...] IDENT[@|/]VERSION [-- FLOCO-CMD-ARGS...]

Show a package definition ( \`pdef' record ).
";

_help_msg="$_usage_msg
This list will include any \"global\" or \"user\" level declarations made in
associated \`floco-cfg.{nix,json}' files if they exis.
With that in mind, you may wish to avoid creating such declarations in
global/user configs, or setting the ENV vars \`_[gu]_floco_cfg=null'.

OPTIONS
  -m,--more         Show more details.
  -j,--json         Output a JSON list.
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


# ---------------------------------------------------------------------------- #

unset _IDENT _VERSION;
_MORE=;
_JSON=;

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
    -j|--json)     _JSON=:; ;;
    -m|--more)     _MORE=:; ;;
    --) shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'." >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;
    [!@]*@*|@*/*@*)
      _IDENT="${1%@*}";
      _VERSION="${1##*@}";
    ;;
    [!@]*/*|@*/*/*)
      _IDENT="${1%/*}";
      _VERSION="${1##*/}";
    ;;
    *)
      if [[ -n "${_IDENT:-}${_VERSION:-}" ]]; then
        echo "$_as_me: Unexpected argument(s) '$*'." >&2;
        printf '\n' >&2;
        usage -f >&2;
        exit 1;
      elif [[ "$#" -lt 2 ]]; then
        echo "$_as_me: Missing argument to indicate VERSION." >&2;
        printf '\n' >&2;
        usage -f >&2;
        exit 1;
      else
        _IDENT="$1";
        shift;
        _VERSION="$1";
      fi
    ;;
  esac
  shift;
done

if [[ -z "${_IDENT:-}" ]]; then
  if [[ -r ./info.nix ]]; then
    _IDENT="$( $NIX eval --raw -f ./info.nix ident; )";
    _VERSION="$( $NIX eval --raw -f ./info.nix version; )";
  elif [[ -r ./info.json ]]; then
    _IDENT="$( $JQ -r '.ident' ./info.json; )";
    _VERSION="$( $JQ -r '.version"' ./version.json; )";
  elif [[ -r ./package.json ]]; then
    _IDENT="$( $JQ -r '.name' ./package.json; )";
    _VERSION="$( $JQ -r '.version // "0.0.0-0"' ./package.json; )";
  else
    echo "$_as_me: Missing argument \`IDENT'." >&2;
    printf '\n' >&2;
    usage >&2;
    exit 1;
  fi
fi


# ---------------------------------------------------------------------------- #

# Load common helpers
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../common.sh
. "${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/../common.sh}";


# ---------------------------------------------------------------------------- #

_NIX_APPLY=;
if [[ -n "${_MORE:-}" ]]; then
  _NIX_APPLY='pdef: let
    r = removeAttrs pdef [
      "sourceInfo" "_export" "metaFiles" "deserialized"
    ];
    noFilter = r // {
      fetchInfo = removeAttrs r.fetchInfo ["filter"];
    };
  in if ! ( r ? fetchInfo.filter ) then r else
     builtins.trace "WARNING: Omitting `fetchInfo.filter'"'"'." noFilter
  ';
else
  _NIX_APPLY='pdef: pdef._export';
fi


# ---------------------------------------------------------------------------- #

runShow() {
  flocoEval                                             \
    "${_NIX_ARGS[@]}" "$@"                              \
    "mod.config.floco.pdefs.\"$_IDENT\".\"$_VERSION\""  \
    --apply "$_NIX_APPLY"                               \
  ;
}

if [[ -n "${_JSON:-}" ]]; then
  runShow --json "$@"|$JQ;
else
  _rdir="${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/../common.sh}";
  _rdir="${_rdir%/*}";
  # shellcheck source-path=SCRIPTDIR
  # shellcheck source=../nix-edit/fmt.sh
  . "$_rdir/nix-edit/fmt.sh";
  runShow "$@"|_nix_fmt;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
