#! /usr/bin/env bash
# ============================================================================ #
#
# Helpers to locate `floco' configuration files.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${_as_me:=configs.sh}";


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${REALPATH:=realpath}";
export REALPATH;


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Source Helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=./search-up.sh
. "$FLOCO_LIBDIR/search-up.sh";


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  # If an argument is given print ref associated with the given directory.
  if [[ "$#" -gt 1 ]]; then
    echo "$_as_me: You may pass at most a single argument." >&2;
    exit 1;
  elif [[ "$#" -gt 0 ]]; then
    if [[ -d "$1" ]]; then
      pushd "$1" >/dev/null||exit;
    else
      echo "$_as_me: No such directory '$1'." >&2;
      exit 1;
    fi
  fi
fi


# ---------------------------------------------------------------------------- #

# Set the var `_g_floco_cfg' to the "global" floco config file if it exists.
if [[ -z "${_g_floco_cfg+y}" ]]; then
  if [[ -r /etc/floco/floco-cfg.nix ]]; then
    export _g_floco_cfg='/etc/floco/floco-cfg.nix';
  elif [[ -r /etc/floco/floco-cfg.json ]]; then
    export _g_floco_cfg='/etc/floco/floco-cfg.json';
  else
    export _g_floco_cfg=;
  fi
fi


# ---------------------------------------------------------------------------- #

# Set the var `_u_floco_cfg' to the "user" floco config file if it exists.
: "${XDG_CONFIG_HOME:=${HOME:-/homeless/shelter}/.config}";
export XDG_CONFIG_HOME;

if [[ -z "${_u_floco_cfg+y}" ]]; then
  if [[ -r $XDG_CONFIG_HOME/floco/floco-cfg.nix ]]; then
    export _u_floco_cfg="$XDG_CONFIG_HOME/floco/floco-cfg.nix";
  elif [[ -r $XDG_CONFIG_HOME/floco/floco-cfg.json ]]; then
    export _u_floco_cfg="$XDG_CONFIG_HOME/floco/floco-cfg.json";
  else
    export _u_floco_cfg=;
  fi
fi


# ---------------------------------------------------------------------------- #

: "${_l_floco_cfg=}";
export _l_floco_cfg;

# Lazily locate the closest `floco-cfg.{json,nix}' between `PWD' and the closest
# repository root, or filesystem root.
localFlocoCfg() {
  if [[ -z "${_l_floco_cfg:=$( searchUp floco-cfg.nix||:; )}" ]]; then
    if [[ -z "${_l_floco_cfg:=$( searchUp floco-cfg.json||:; )}" ]]; then
      echo "$_as_me: no floco-cfg.nix or floco-cfg.json found" >&2;
      return 1;
    fi
  fi
  export _l_floco_cfg;
  echo "$_l_floco_cfg";
}
export -f localFlocoCfg;


# ---------------------------------------------------------------------------- #

# Print all the floco config files that are "in scope".
flocoCfgFiles() {
  if [[ -n "$_g_floco_cfg" ]]; then echo "$_g_floco_cfg"; fi
  if [[ -n "$_u_floco_cfg" ]]; then echo "$_u_floco_cfg"; fi
  if [[ -n "$( localFlocoCfg 2>/dev/null||:; )" ]]; then localFlocoCfg; fi
}
export -f flocoCfgFiles;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # Make this file usable as a script.
  # A similar block above handles changing `PWD'.
  flocoCfgFiles;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
