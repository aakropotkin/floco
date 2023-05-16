#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo "common.sh: You must source this script, it is not runnable." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${GREP:=grep}";
: "${HEAD:=head}";
: "${JQ:=jq}";
: "${MKTEMP:=mktemp}";
: "${NIX:=nix}";
: "${REALPATH:=realpath}";
export GREP HEAD JQ MKTEMP NIX REALPATH;


# ---------------------------------------------------------------------------- #

FLOCO_LIBDIR="$( $REALPATH "${BASH_SOURCE[0]%/*}"; )";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./dirs.sh
. "$FLOCO_LIBDIR/dirs.sh";
setScriptVars "$0" "${BASH_SOURCE[@]:1}";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./search-up.sh
. "$FLOCO_LIBDIR/search-up.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./floco-ref.sh
. "$FLOCO_LIBDIR/floco-ref.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./nix-system.sh
. "$FLOCO_LIBDIR/nix-system.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./configs.sh
. "$FLOCO_LIBDIR/configs.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./floco-cmd.sh
. "$FLOCO_LIBDIR/floco-cmd.sh";


# ---------------------------------------------------------------------------- #

declare -ax _tmp_files _tmp_dirs;
if ! declare -p _tmp_files >/dev/null 2>&1; then _tmp_files=(); fi
if ! declare -p _tmp_dirs >/dev/null 2>&1;  then _tmp_dirs=(); fi

_tmpAuto=;
export _tmpAuto;

mktmpAuto() {
  local _f;
  _tmpAuto=;
  _f="$( $MKTEMP "$@"; )";
  if [[ -n "${_TRACE:-}" ]]; then
    echo "${_as_me:-floco:lib/common.sh}: mktmpAuto $*  --> $_f" >&2;
  fi
  if [[ -d "$_f" ]]; then
    _tmp_dirs+=( "$_f" );
  else
    _tmp_files+=( "$_f" );
  fi
  _tmpAuto="$_f";
}
export -f mktmpAuto;


# ---------------------------------------------------------------------------- #

commonCleanup() {
  rm -f "${_tmp_files[@]}";
  case " ${_tmp_dirs[*]} " in
    \ "$PWD"\ ) cd / >/dev/null; ;;
    *) :; ;;
  esac
  rm -rf "${_tmp_dirs[@]}";
}
export -f commonCleanup;

cleanupHooks="commonCleanup";
export cleanupHooks;


addCleanupHook() {
  for h in "$@"; do
    case " ${cleanupHooks:-} " in
      *\ "$h"\ *) :; ;;
      *) cleanupHooks="${cleanupHooks:+$cleanupHooks }$h"; ;;
    esac
  done
  export cleanupHooks;
}
export -f addCleanupHook;


cleanup() {
  local _hook _cleanupHooks;
  read -ra _cleanupHooks <<< "$cleanupHooks";
  for _hook in "${_cleanupHooks[@]}"; do
    if [[ -n "${_TRACE:-}" ]]; then
      echo "${_as_me:-floco:lib/common.sh}: running cleanupHook '$_hook'." >&2;
    fi
    "$_hook";
  done
}
export -f cleanup;


_es=0;
trap '
_es="$?";
cleanup;
exit "$_es";
' HUP TERM INT QUIT EXIT;


# ---------------------------------------------------------------------------- #

helpUrls() {
  echo "Report bugs to: <https://github.com/aakropotkin/floco/issues>";
  echo "floco home page: <https://github.com/aakropotkin/floco>";
  echo "Matrix chat support room: \
<https://matrix.to/#/!tBPFHeGmZfhbuYgvcw:matrix.org?via=matrix.org>";
}
export -f helpUrls;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
