#! /usr/bin/env bash
# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="floco";

_version="0.1.0";

_usage_msg="Usage: $_as_me [OPTIONS]... {list|build|show|edit|help} [ARGS]...;

COMMANDS
  list                    List available packages.
  build [KEY] [TARGET]    Build a target for a package.
  show [KEY]              Show declared package definition ( \`pdef' ).
  translate [DESCRIPTOR]  Translate module metadata to \`pdefs.{nix,json}'.
  edit FILE               Edit a trivial Nix file with an expression.
  help CMD                Show help for \`CMD'.
";

_help_msg="$_usage_msg
OPTIONS
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
  NPM               Command used as \`npm' executable.
  XDG_CONFIG_HOME   Used to find \`XDG_CONFIG_HOME/floco/floco-cfg.{nix,json}'.
  _g_floco_cfg      Path to global floco config file. May be set to \`null'.
  _u_floco_cfg      Path to user floco config file. May be set to \`null'.
  FLOCO_CONFIG      Path to a \`floco' configuration file. Used as \`--config'.
  FLOCO_REF         Flake URI ref to use for \`floco'.
                    defaults to \`github:aakropotkin/floco'.
  DEBUG             Show \`nix' backtraces.
";


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${GREP:=grep}";
: "${HEAD:=head}";
: "${JQ:=jq}";
: "${MKTEMP:=mktemp}";
: "${NIX:=nix}";
: "${REALPATH:=realpath}";

export GREP HEAD JQ MKTEMP NIX REALPATH;

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./common.sh
. "${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/common.sh}";


# ---------------------------------------------------------------------------- #

usage() {
  if [[ "${1:-}" = "-f" ]]; then
    echo "$_help_msg";
    helpUrls;
  else
    echo "$_usage_msg";
  fi
}


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
    --) shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;

    help)
      if [[ "$#" -lt 2 ]]; then
        echo "$_as_me: Missing argument for \`help'." >&2;
        printf '\n' >&2;
        usage >&2;
        exit 1;
      fi
      shift;
      case "$1" in
        build)              "$SDIR/build/build-target.sh" --help; ;;
        list)               "$SDIR/list/list-pdefs.sh" --help; ;;
        show)               "$SDIR/show/show-pdefs.sh" --help; ;;
        # TODO: merge `from-plock.sh' and `from-registry.sh'
        translate|trans|x)  "$SDIR/translate/from-plock.sh" --help; ;;
        edit)               "$SDIR/nix-edit/edit.sh"   --help; ;;
        *)
          echo "$_as_me help: Unrecognized subcommand: \`$2'." >&2;
          printf '\n' >&2;
          usage >&2;
          exit 1;
        ;;
      esac
      helpUrls;
      exit 0;
    ;;

    list)
      shift;
      exec "$SDIR/list/list-pdefs.sh" "$@";
    ;;

    build)
      shift;
      exec "$SDIR/build/build-target.sh" "$@";
    ;;

    show)
      shift;
      exec "$SDIR/show/show-pdefs.sh" "$@";
    ;;

    translate|trans|x)
      shift;
      skip=;
      isLocal=:;
      for a in "$@"; do
        if [[ -n "$skip" ]]; then
          skip=;
          continue;
        fi
        case "$a" in
          -l|--lock-dir|--lockdir) isLocal=:; break; ;;
          -o|--out-file|--outfile) skip=:; ;;
          -c|--config) skip=:; ;;
          --) break; ;;
          -*) continue; ;;
          *) isLocal=; break; ;;
        esac
      done
      if [[ -n "${isLocal:-}" ]]; then
        exec "$SDIR/translate/from-plock.sh" "$@";
      else
        exec "$SDIR/translate/from-registry.sh" "$@";
      fi
    ;;

    edit)
      shift;
      exec "$SDIR/nix-edit/edit.sh" "$@";
    ;;

    *)
      echo "$_as_me: Unexpected argument(s) '$*'." >&2;
      printf '\n' >&2;
      usage -f >&2;
      exit 1;
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

echo "$_as_me: No command given." >&2;
printf '\n' >&2;
usage >&2;
exit 1;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
