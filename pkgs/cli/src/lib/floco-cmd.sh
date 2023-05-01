#! /usr/bin/env bash
# ============================================================================ #
#
# Evaluates a `nix' expression wrapped with various args for `floco'.
# This is used to reduce boilerplate and promote consistency across commands.
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_cmd_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${REALPATH:=realpath}";
: "${NIX:=nix}";
export REALPATH NIX;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source Helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./dirs.sh
. "$FLOCO_LIBDIR/dirs.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./configs.sh
. "$FLOCO_LIBDIR/configs.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./nix-system.sh
. "$FLOCO_LIBDIR/nix-system.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./floco-ref.sh
. "$FLOCO_LIBDIR/floco-ref.sh";


# ---------------------------------------------------------------------------- #

flocoCmd() {
  local _cmd _dir _old_l_floco_cfg _passthru;
  _cmd="$1";
  shift;

  _old_l_floco_cfg="$( localFlocoCfg 2>/dev/null||:; )";
  unset _l_floco_cfg;

  _passthru=();

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

      -f|--file)
        shift;
        _file="$1";
      ;;

      *)
        if [[ -z "${_dir:-}" ]] && [[ -d "$1" ]]; then
          _dir="$1";
        else
          _passthru+=( "$1" );
        fi
      ;;
    esac
    shift
  done

  : "${_dir:=$PWD}";
  : "${_file:=$FLOCO_NIXDIR/common.nix}";

  # NOTE: for `nix eval' the `--arg[str]' options are ignored which is
  # incredibly obnoxious...

  # Disable complaints about `_[ug]_floco_cfg' which are set by `configs.sh'.
  #shellcheck disable=SC2154
  $NIX "$_cmd" -f "$_file"                                      \
    --argstr system    "$( nixSystem; )"                        \
    --argstr flocoRef  "$( flocoRef; )"                         \
    --argstr globalConfig "$_g_floco_cfg"                       \
    --argstr userConfig   "$_u_floco_cfg"                       \
    --argstr localConfig  "$( localFlocoCfg 2>/dev/null||:; )"  \
    "${_passthru[@]}"                                           \
  ;

  _l_floco_cfg="$_old_l_floco_cfg";
}
export -f flocoCmd;


# ---------------------------------------------------------------------------- #

flocoEval()  { flocoCmd eval "$@"; }
flocoBuild() { flocoCmd build "$@"; }
export -f flocoEval flocoBuild;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  flocoCmd "$@";
else
  export _floco_cli_cmd_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
