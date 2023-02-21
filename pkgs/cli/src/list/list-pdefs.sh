#! /usr/bin/env bash
# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# List all known packages declared in a given directory.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${_as_main=floco}";
_as_sub='list';
_as_me="$_as_main $_as_sub";

: "${_version:=0.1.0}";

_usage_msg="Usage: $_as_me [OPTIONS...] [-- FLOCO-CMD-ARGS...]

List all known packages declared in a given directory.
";

_help_msg="$_usage_msg
This list will include any \"global\" or \"user\" level declarations made in
associated \`floco-cfg.{nix,json}' files if they exis.
With that in mind, you may wish to avoid creating such declarations in
global/user configs, or setting the ENV vars \`_[gu]_floco_cfg=null'.

OPTIONS
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
    --) shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      echo "$_as_me: Unexpected argument(s) '$*'" >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

# Load common helpers
# shellcheck source=../common.sh
. "${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/../common.sh}";


# ---------------------------------------------------------------------------- #

declare -a _JQ_ARGS;
_JQ_ARGS=( '-r' );
if [[ -z "${_JSON:-}" ]]; then
  _JQ_ARGS+=( '.[]' );
fi

flocoEval --json "$@" mod.config.floco.pdefs --apply 'pdefs:
builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( ident: vs:
  builtins.attrValues (
    builtins.mapAttrs ( version: _: ident + "/" + version ) vs
  )
) pdefs ) )
'|$JQ "${_JQ_ARGS[@]}";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
