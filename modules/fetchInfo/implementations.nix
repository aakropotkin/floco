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

    fetchTree.tarball = { config, ... }: {
      type    = "tarball";
      narHash = (builtins.fetchTree {
        type = "tarball";
        inherit (config) url;
      }).narHash;
    } // config;

    fetchTree.file = { config, ... }: {
      type    = "file";
      narHash = (builtins.fetchTree {
        type = "file";
        inherit (config) url;
      }).narHash;
    } // config;

    fetchTree.github = { config, ... }: {
      type = "github";
      rev  = (builtins.fetchTree {
        type = "github";
        inherit (config) owner repo ref;
      }).rev;
    } // config;

    fetchTree.git = { config, ... }: {
      type = "git";
      rev  = (builtins.fetchTree {
        type = "github";
        inherit (config) owner repo ref;
      }).rev;
    } // config;

    fetchTree.any = { config, ... } @ args:
      optDefs.fetchTree.${config.type} args;

    path = { config, ... }: {
      sha256 = (builtins.fetchTree {
        type = "path";
        path = builtins.path config;
      }).narHash;
    } // config;

    fetchInfo = { config, ... } @ args:
      if config ? type then optDefs.fetchTree.${config.type} args else
      optDefs.path args;

  };  # End `optDefs'


# ---------------------------------------------------------------------------- #

in optDefs


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
