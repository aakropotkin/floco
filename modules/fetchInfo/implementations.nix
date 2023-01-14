# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# These implementations lock unlocked configs.
#
# NOTE: These are regular functions and do NOT treat `config' recursively.
# They must not be used in a module fixed point.
# Translators should call these functions directly in their own implementation
# files when they need to lock fetchInfo.
#
# Honestly some of this module shit is nauseating - the type system was really
# not intended to handle polymorphism and while you /could/ make it work it
# quickly becomes an incomprehensible mess.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  ft = import ./types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

  optDefs = {

    fetchTree.any = { config, ... } @ args:
      optDefs.fetchTree.${config.type} args;
    } // config;

    fetchInfo = { config, ... } @ args:
      if optDefs.fetchTree ? ${config.type or "unknown"}
      then optDefs.fetchTree.${config.type} args
      else optDefs.path args;

  };  # End `optDefs'


# ---------------------------------------------------------------------------- #

in optDefs


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
