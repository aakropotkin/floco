# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# These implementations lock unlocked configs.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  ft = import ./types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

  optDefs = {

    fetchTree.tarball = { config, ... }: {
      type = lib.mkDefault "tarball";
      narHash = lib.mkDefault (builtins.fetchTree {
        type = "tarball";
        inherit (config) url;
      }).narHash;
    };

    fetchTree.file = { config, ... }: {
      type    = lib.mkDefault "file";
      narHash = lib.mkDefault (builtins.fetchTree {
        type = "file";
        inherit (config) url;
      }).narHash;
    };

    fetchTree.github = { config, ... }: {
      type = "github";
      rev  = lib.mkDefault (builtins.fetchTree {
        type = "github";
        inherit (config) owner repo ref;
      }).rev;
    };

    fetchTree.git = { config, ... }: {
      type = "git";
      rev  = lib.mkDefault (builtins.fetchTree {
        type = "github";
        inherit (config) owner repo ref;
      }).rev;
    };

    fetchTree.any = { config, ... } @ args:
      optDefs.fetchTree.${config.type} args;

    path = { config, ... }: {
      sha256 = lib.mkDefault (builtins.fetchTree {
        type = "path";
        path = builtins.path config;
      }).narHash;
    };

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
