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

if [[ -n "${_floco_cli_common_sourced:-}" ]]; then return 0; fi


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

if [[ "${#BASH_SOURCE[@]}" -gt 1 ]]; then
  SPATH="$( $REALPATH "${BASH_SOURCE[1]}"; )";
else
  SPATH="$PWD/interactive";
fi

SDIR="${SPATH%/*}";
: "${_as_me:=${SPATH##*/}}";

export SPATH SDIR _as_me;

FLOCO_LIBDIR="$( $REALPATH "${BASH_SOURCE[0]%/*}"; )";
FLOCO_LIBEXECDIR="$( $REALPATH "$FLOCO_LIBDIR/../libexec"; )";
FLOCO_NIXDIR="$( $REALPATH "$FLOCO_LIBDIR/../nix"; )";
FLOCO_NIX_LIBDIR="$( $REALPATH "$FLOCO_NIXDIR/lib"; )";
export FLOCO_LIBDIR FLOCO_LIBEXECDIR FLOCO_NIXDIR FLOCO_NIX_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source helpers

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

declare -a _tmp_files _tmp_dirs;
_tmp_files=();
_tmp_dirs=();
export _tmp_files _tmp_dirs;

mktmpAuto() {
  local _f;
  _f="$( $MKTEMP "$@"; )";
  case " $* " in
    *\ -d\ *|*\ --directory\ *) _tmp_dirs+=( "$_f" ); ;;
    *)                          _tmp_files+=( "$_f" ); ;;
  esac
  echo "$_f";
}
export -f mktmpAuto;


# ---------------------------------------------------------------------------- #

commonCleanup() {
  rm -f "${_tmp_files[@]}";
  rm -rf "${_tmp_dirs[@]}";
}
export -f commonCleanup;

declare -a cleanupHooks;
cleanupHooks=( commonCleanup );
export cleanupHooks;

cleanup() {
  local _hook;
  for _hook in "${cleanupHooks[@]}"; do
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

export _floco_cli_common_sourced=:;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
