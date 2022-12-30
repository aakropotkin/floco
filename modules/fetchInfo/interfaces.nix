# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  ft = import ./types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

  fetchTree.tarball = lib.mkOption {
    description = "`builtins.fetchTree[tarball]' args";
    type        = ft.fetchTree.tarball;
  };

  fetchTree.file = lib.mkOption {
    description = "`builtins.fetchTree[file]' args";
    type        = ft.fetchTree.file;
  };

  fetchTree.github = lib.mkOption {
    description = "`builtins.fetchTree[github]' args";
    type        = ft.fetchTree.github;
  };

  fetchTree.git = lib.mkOption {
    description = "`builtins.fetchTree[git]' args";
    type        = ft.fetchTree.git;
  };

  fetchTree.any = lib.mkOption {
    description = "`builtins.fetchTree' args";
    type        = ft.fetchTree.any;
  };

  path = lib.mkOption {
    description = "`builtins.path' args";
    type        = ft.path;
  };

  fetchInfo = lib.mkOption {
    description = "Arguments for a builtins fetcher";
    type        = ft.fetchInfo;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
