# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
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
    description = ''
      Arguments passed to fetcher.
      By default any `builtins.fetchTree' or `builtins.path' argset is
      supported, and the correct fetcher can be inferred from these values.

      If set to `null', `sourceInfo' must be set explicitly.
    '';
    type = ( nt.submodule {
      freeformType =
        nt.attrsOf ( nt.nullOr ( nt.oneOf [nt.str nt.path nt.int nt.bool] ) );
    } ) // { inherit (ft.fetchInfo) check; };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
