#! /usr/bin/env bash
# ============================================================================ #
#
# Helper function which looks up the flake URI ( "flake reference" ) to use
# for `floco'.
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_floco_ref_sourced:-}" ]]; then
  return 0;
fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=${BASH_SOURCE[0]%/*}}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source helpers

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./search-up.sh
. "$FLOCO_LIBDIR/search-up.sh";


# ---------------------------------------------------------------------------- #

: "${JQ:=jq}";
: "${NIX:=nix}";
: "${GREP:=grep}";
: "${HEAD:=head}";
export JQ NIX GREP HEAD;


# ---------------------------------------------------------------------------- #

# Try to find a flake ref to `floco' by searching in `flake.lock' files, and
# `nix registry'.
: "${_floco_ref=}";
export _floco_ref;

flocoRef() {
  : "${_floco_ref=}";
  if [[ -n "$_floco_ref" ]]; then
    echo "$_floco_ref";
    return 0;
  fi

  local flock;
  if [[ -n "${flock=$( searchUp flake.lock||:; )}" ]]; then
    if $JQ -e '.nodes|has("floco")' "$flock" >/dev/null; then
      #shellcheck disable=SC2016
      _floco_ref="$( $JQ -r '
.nodes.floco.locked as $locked|
if $locked.type == "path" then
  "path:" + $locked.path
else
  if $locked.type == "github" then
    "github:" + $locked.owner + "/" + $locked.repo + "/" + $locked.rev
  else
    if $locked.url|test( "narHash=" ) then
      $locked.type + $locked.url
    else
      if $locked.url|test( "\\?" ) then
        $locked.type + $locked.url + "&narHash=" + $locked.narHash
      else
        $locked.type + $locked.url + "?narHash=" + $locked.narHash
      end
    end
  end
end
' "$flock"; )";
      echo "$_floco_ref";
      return 0;
    fi
  fi
  _floco_ref="$(
    {
      { $NIX registry list|$GREP ' flake:floco '; }               \
        || echo 'fallback flake:floco github:aakropotkin/floco';
    }|$HEAD -n1;
  )";
  _floco_ref="${_floco_ref##* }";

  echo "$_floco_ref";
}
export -f flocoRef;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Make this file usable as a script.
  # If an argument is given print ref associated with the given directory.
  if [[ "$#" -gt 1 ]]; then
    echo "floco-ref.sh: You may pass at most a single argument." >&2;
    exit 1;
  elif [[ "$#" -gt 0 ]]; then
    if [[ -d "$1" ]]; then
      pushd "$1" >/dev/null||exit;
    else
      echo "floco-ref.sh: No such directory '$1'." >&2;
      exit 1;
    fi
  fi
  flocoRef;
else
  export _floco_cli_floco_ref_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
