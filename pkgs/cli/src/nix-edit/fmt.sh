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

: "${NIX:=nix}";
: "${SED:=sed}";

export NIX SED;


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


# ---------------------------------------------------------------------------- #

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


# ---------------------------------------------------------------------------- #

_nix_fmt() {
  #shellcheck disable=SC2119
  $NIX eval --raw -f "${1:-/dev/stdin}" --apply 'e: let
    nixpkgs = builtins.getFlake "nixpkgs";
    inherit (nixpkgs) lib;
  in ( lib.generators.toPretty {} e ) + "\n"
  '|_nix_keyword_escape;
}


# ---------------------------------------------------------------------------- #

_nix_fmt_rewrite() {
  # For `mktmpAuto'.
  # shellcheck source-path=SCRIPTDIR
  # shellcheck source=../common.sh
  . "${_FLOCO_COMMON_SH:-${BASH_SOURCE[0]%/*}/../common.sh}";
  local _tmpfile;
  #shellcheck disable=SC2119
  _tmpfile="$( mktmpAuto; )";
  for f in "$@"; do
    _nix_fmt "$f" > "$_tmpfile";
    mv "$_tmpfile" "$f";
  done
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
