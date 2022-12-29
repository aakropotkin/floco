#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail

# ---------------------------------------------------------------------------- #

_as_me='floco run';

_usage_msg="
run-script.sh [OPTIONS] SCRIPT-NAME [SCRIPT-NAMES...]

Run one or more scripts from \`package.json' in a wrapped runtime environment.
This script must be run from a directory containing a \`package.json' file.
";

_help_msg="
$_usage_msg

OPTIONS
  -P,--no-modify-path   Do not modify \`PATH' with bin directories
  -i,--ignore-missing   Do not throw an error if a script is undefined
  -B,--no-parent-bins   Do not search up for bin directories
  -u,--usage            Print usage message to STDOUT
  -h,--help             Print this message to STDOUT

ENVIRONMENT
The following environment variables may be used to locate various executables
or in place of options/flags.
Presence of flags will always take priority over environment variables.

  NO_MODIFY_PATH    Do not modify \`PATH' with bin directories.
  NO_PARENT_BINS    Do not search up for bin directories.
  IGNORE_MISSING    Do not throw an error if a script is undefined.
                    Setting to any non-empty string enables this setting.
  NODEJS            Absolute path to \`node' executable.     ( Optional )
  JQ                Absolute path to \`jq' executable.       ( Optional )
  BASH              Absolute path to \`bash' executable.     ( Optional )
";


# ---------------------------------------------------------------------------- #

usage() {
  echo "$_usage_msg";
  [[ "${1:-}" = "-f" ]] && echo "$_help_msg";
}


# ---------------------------------------------------------------------------- #

if [[ ! -r ./package.json ]]; then
  if [[ ! -e ./package.json ]]; then
    echo "$_as_me: No \`$PWD/package.json' file found." >&2;
  else
    echo "$_as_me: Cannot read \`$PWD/package.json'." >&2;
  fi
  echo '' >&2;
  usage >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

: "${JQ:=jq}";
: "${BASH:=bash}";
: "${NODEJS:=node}";

declare -a SCRIPTS;
SCRIPTS=();

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -P|--no-modify-path) NO_MODIFY_PATH=:; ;;
    -B|--no-parent-bins) NO_PARENT_BINS=:; ;;
    -i|--ignore-missing) IGNORE_MISSING=:; ;;
    -u|--usage)          usage;    exit 0; ;;
    -h|--help)           usage -f; exit 0; ;;
    *)                   scripts+=( "$1" ); ;;
  esac
  shift;
done

: "${IGNORE_MISSING=}";
: "${NO_PARENT_BINS=}";
: "${NO_MODIFY_PATH=}";

if [[ "${#SCRIPTS[@]}" -le 0 ]]; then
  echo "$_as_me: You must provide the names of one or more scripts." >&2;
  usage >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

# Set `PATH', adding bin directories
if [[ -z "$NO_MODIFY_PATH" ]]; then
  PATH="$PATH:$PWD/node_modules/.bin";
  # Search upwards into parent directories for additional `node_modules/.bin'
  # directories until finding a `.git/' directory, a nix store ceiling,
  # or the filesystem root.
  if [[ -z "$NO_PARENT_BINS" ]]; then
    _curr="${PWD%/*}";
    while [[ "$_curr" != "/" ]]; do
      if [[ -d "$_curr/node_modules/.bin" ]]; then
        PATH="$PATH:$_curr/node_modules/.bin";
      fi
      if [[ -d "$_curr/.git" ]]; then
        break;
      fi
      _curr="${_curr%/*}";
      case "$_curr" in
        "${NIX_STORE:-/nix/store}") break; ;;
        *) :; ;;
      esac
    done
    unset _curr;
  fi
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
