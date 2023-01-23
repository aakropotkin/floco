#! /usr/bin/env bash
# ============================================================================ #
#
# Strip `#! /nix/store/.../bin/foo' to `#! /user/bin/env/foo' is scripts.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail

# ---------------------------------------------------------------------------- #

_as_me='floco unpatch';

_version='0.1.0';

_usage_msg="Usage: unpatch-shebangs.sh [OPTIONS] SCRIPT [SCRIPT...]

Unpatch shebang lines in scripts so that they can be run outside of Nix.
";

_help_msg="$_usage_msg
Options:
  -u,--usage              Print usage message to STDOUT
  -h,--help               Print this message to STDOUT
  -V,--version            Print version to STDOUT

Environment:
  The following environment variables may be used to locate various executables
  or in place of options/flags.

  Variables marked as \"Bool\" are treated as false when unset or set to the
  empty string, or true for any non-empty value.
  Flags will always take priority over environment variables.

  CHMOD             Absolute path to \`chmod' executable.
  TAIL              Absolute path to \`tail' executable.
  NIX_STORE         Absolute path to your Nix store. Default: \`/nix/store'.
";
  #FIND              Absolute path to \`find' executable.


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
: "${TAIL:=tail}";
: "${CHMOD:=chmod}";

declare -a SCRIPTS;
SCRIPTS=();

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      while read -r -n1 opt; do
        if [[ -z "$opt" ]]; then
          break;
        fi
        _args+=( "-$opt" );
      done <<<"${_arg#-}";
      set -- "${_args[@]}" "$@";
      unset _arg _args;
      continue;
    ;;
    -u|--usage)   usage;    exit 0; ;;
    -h|--help)    usage -f; exit 0; ;;
    -v|--version) echo "$_version"; exit 0; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *) SCRIPTS+=( "$1" ); ;;
  esac
  shift;
done

: "${NIX_STORE:=/nix/store}";

if [[ "${#SCRIPTS[@]}" -le 0 ]]; then
  echo "$_as_me: You must provide the names of one or more scripts." >&2;
  usage >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

# Identical to `<nixpkgs>/pkgs/stdenv/generic/setup.sh'
pjsIsScript() {
  local fn="$1";
  local fd;
  local magic;
  exec {fd}< "$fn";
  read -r -n 2 -u "$fd" magic;
  exec {fd}<&-
  if [[ "$magic" =~ \#! ]]; then
    return 0;
  else
    return 1;
  fi
}


unpatchShebang() {
  local timestamp oldInterpreterLine newInterpreterLine oldPath arg0 args;
  pjsIsScript "$1"||return 0;
  read -r oldInterpreterLine < "$1";
  read -r oldPath arg0 args <<< "${oldInterpreterLine:2}";
  # Only modify `node' shebangs.
  case "$oldPath" in
    $NIX_STORE/*) :; ;;
    *) return 0; ;;
  esac
  newInterpreterLine="#! /usr/bin/env ${oldPath##*/}";
  newInterpreterLine="$newInterpreterLine${arg0:+ $arg0}${args:+ $args}";
  timestamp="$( stat --printf '%y' "$1"; )";
  printf '%s'                                                         \
    "$1: interpreter directive changed from \"$oldInterpreterLine\""  \
    " to \"${newInterpreterLine:?}\"" >&2;
  echo '' >&2;
  {
    echo "$newInterpreterLine";
    $TAIL -n +2 "$1";
  } > "$1~";
  $CHMOD 0755 "$1~";
  mv -- "$1~" "$1";
  touch --date "$timestamp" "$1";
}


# ---------------------------------------------------------------------------- #

for bp in $SCRIPTS; do
  unpatchShebang "${bp#*,}";
done


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
