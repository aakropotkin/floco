#! /usr/bin/env bash
# ============================================================================ #
#
# Print the running machine's `nix' system pair.
# Examples:  x86_64-linux, aarch64-linux, x86_64-darwin, etc...
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_nix_system_sourced:-}" ]]; then return 0; fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${NIX:=nix}"
export NIX;


# ---------------------------------------------------------------------------- #

# Records the running system pair as recognized by `nix CMD --system SYSTEM'.
: "${_nix_system=}";
export _nix_system;

nixSystem() {
  if [[ -z "$_nix_system" ]]; then
    _nix_system="$( $NIX eval --raw --impure --expr builtins.currentSystem; )";
  fi
  echo "$_nix_system";
  export _nix_system;
}
export -f nixSystem;


# ---------------------------------------------------------------------------- #

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Make this file usable as a script.
  nixSystem;
else
  export _floco_cli_nix_system_sourced=:;
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
