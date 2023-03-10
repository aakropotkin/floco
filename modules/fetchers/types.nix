# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  types = {

# ---------------------------------------------------------------------------- #

    sha256_hash = nt.strMatching "[[:xdigit:]]{64}";
    sha256_sri  = nt.strMatching "sha256-[a-zA-Z0-9+/]{42,44}={0,2}";
    narHash     = types.sha256_sri;

# ---------------------------------------------------------------------------- #

    rev       = nt.strMatching "[[:xdigit:]]{40}";
    short_rev = nt.strMatching "[[:xdigit:]]{7}";


# ---------------------------------------------------------------------------- #

  };

in types


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
