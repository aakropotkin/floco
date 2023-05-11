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

: "${_version:=0.2.0}";

_usage_msg="Usage: $_as_me [OPTIONS]... [-- FLOCO-CMD-ARGS]...

List all known packages declared in a given directory.
";

_help_msg="$_usage_msg
This list will include any \"global\" or \"user\" level declarations made in
associated \`floco-cfg.{nix,json}' files if they exis.
With that in mind, you may wish to avoid creating such declarations in
global/user configs, or setting the ENV vars \`_[gu]_floco_cfg=null'.

OPTIONS
  -j,--json         Output a JSON list.
  -f,--filter PRED  Filter results to those satisfying predicate filter.
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

FILTERS
Predicate used by \`--filter' option must be one of the following predefined
functions defined in \`<floco>/lib/pdef-filters.nix'.
  hasInstall        Package has a [pre|post]install script.
  hasBuild          Package has a [pre|post]build script.
  isLocal           Package's source is fetched from a local path.
  isRemote          Package's source is fetched from a remote host.
  isGit             Package's source is a \`git' repository.
  isTarball         Package's source is a tarball.
  hasPeers          Package has peer dependencies.
  hasBundled        Package has bundled dependencies.
  needsOS           Package supports a limited set of Operating Systems.
  needsCPU          Package supports a limited set of CPU architectures.
  needsNodeVersion  Package supports a limited range of Node versions.
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
    -f|--filter)   _FILTER="$2"; shift; ;;
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

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}/../lib"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Load common helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../lib/common.sh
. "$FLOCO_LIBDIR/common.sh";


# ---------------------------------------------------------------------------- #

declare -a _named_filters;
#shellcheck disable=SC2207
_named_filters=( $(
  flocoEval --raw "lib.libfloco.pdefFilters.noArgs"                       \
    --apply 'f: builtins.concatStringsSep " " ( builtins.attrNames f )';
) );

if [[ -n "${_FILTER:-}" ]]; then
  case " ${_named_filters[@]} " in
    *\ "$_FILTER"\ *) _FILTER="lib.libfloco.pdefFilters.noArgs.$_FILTER"; ;;
    *)
      echo "$_as_me: No such filter '$_FILTER'. Must be one of:" >&2;
      printf ' %s' "" "${_named_filters[@]}" >&2;
      echo '' >&2;
      exit 1;
    ;;
  esac
else
  _FILTER="( _: true )";
fi


# ---------------------------------------------------------------------------- #

declare -a _JQ_ARGS;
_JQ_ARGS=( '-r' );
if [[ -z "${_JSON:-}" ]]; then
  _JQ_ARGS+=( '.[]' );
fi

flocoEval --json "$@" mod.config.floco.pdefs --apply "pdefs: let
  inherit (builtins.getFlake \"$( flocoRef; )\") lib;
in builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( ident: vs:
  builtins.attrValues (
    builtins.mapAttrs ( version: _: ident + \"/\" + version ) vs
  )
) ( lib.libfloco.filterPdefs $_FILTER pdefs ) ) )
"|$JQ "${_JQ_ARGS[@]}";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
