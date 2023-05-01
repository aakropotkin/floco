#! /usr/bin/env bash
# ============================================================================ #
#
# Helper function to escape reserved keys in a Nix attribute set.
#
# This overlaps with the functionality of `lib.libfloco.prettyPrintEscaped'
# without depending on the `floco' repository.
# In practice this is useful to avoid resolving a locked reference to `floco'
# in cases where we really just want to pretty print a Nix attribute set.
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_fmt_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${NIX:=nix}";
: "${SED:=sed}";
: "${REALPATH:=realpath}";
export NIX SED realpath;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

declare -a _nix_edit_escape_keywords;
_nix_edit_escape_keywords=(
  'assert'
  'throw'
  'with'
  'let'
  'in'
  'or'
  'inherit'
  'rec'
  'import'
);
export _nix_edit_escape_keywords;


# ---------------------------------------------------------------------------- #

# _nix_keyword_escape
# -------------------
# Quote/escape reserved keywords read from STDIN and print to STDOUT.
#
#shellcheck disable=SC2120
_nix_keyword_escape() {
  local _patt_from _npatts;
  _npatts="${#_nix_edit_escape_keywords[@]}";
  _patt_from=" \(";
  for k in "${_nix_edit_escape_keywords[@]:0:$(( _npatts - 1 ))}"; do
    _patt_from="$_patt_from$k\|";
  done;
  _patt_from="$_patt_from${_nix_edit_escape_keywords[$(( _npatts - 1 ))]}\) =";
  $SED "s/$_patt_from/ \"\\1\" =/g" "${@:-/dev/stdin}";
}
export -f _nix_keyword_escape;


# ---------------------------------------------------------------------------- #

# _nix_fmt [FILE]
# ---------------
# Reformat/"pretty print" a nix expression and escape reserved keywords.
# Input is read from STDIN or a given file and printed to STDOUT.
_nix_fmt() {
  #shellcheck disable=SC2119
  $NIX eval --raw -f "${1:--}" --apply 'e: let
    nixpkgs = builtins.getFlake "nixpkgs";
    inherit (nixpkgs) lib;
  in ( lib.generators.toPretty {} e ) + "\n"
  '|_nix_keyword_escape;
}
export -f _nix_fmt;


# ---------------------------------------------------------------------------- #

# _nix_fmt_rewrite FILE...
# ------------------------
# Rewrite one or more files.
_nix_fmt_rewrite() {
  # For `mktmpAuto'.
  #shellcheck source-path=SCRIPTDIR
  #shellcheck source=./common.sh
  . "$FLOCO_LIBDIR/common.sh";
  local _tmpfile;
  #shellcheck disable=SC2119
  _tmpfile="$( mktmpAuto; )";
  for f in "$@"; do
    _nix_fmt "$f" > "$_tmpfile";
    mv "$_tmpfile" "$f";
  done
}
export -f _nix_fmt_rewrite;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  # Without args format STDIN.
  # Treat args as file names, printing to STDOUT or rewrite if `-i' is given.
  if [[ "$#" -lt 1 ]]; then
    _nix_fmt -;
  else
    case " $* " in
      *\ -i\ *)
        declare -a _args;
        _args=();
        for f in "$@"; do
          if [[ "$f" != '-i' ]]; then
            _args+=( "$f" );
          fi
        done
        _nix_fmt_rewrite "${_args[@]}";
      ;;
      *)
        for f in "$@"; do
          _nix_fmt "$f";
        done
      ;;
    esac
  fi
else
  export _floco_cli_fmt_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
