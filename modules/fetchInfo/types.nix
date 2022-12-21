# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  fetchTree.tarball = nt.submodule {
    name        = "fetchInfo:tarball";
    description = "`builtins.fetchTree[tarball]' args";
    options     = {
      type    = lib.mkOption {
        type    = nt.enum ["tarball"];
        default = "tarball";
      };
      url     = lib.mkOption { type = nt.str; };
      narHash = lib.mkOption { type = nt.nullOr nt.str; default = null; };
    };
  };


# ---------------------------------------------------------------------------- #

  fetchTree.file = nt.submodule {
    name        = "fetchInfo:file";
    description = "`builtins.fetchTree[file]' args";
    options     = {
      type    = lib.mkOption {
        type    = nt.enum ["file"];
        default = "file";
      };
      url     = lib.mkOption { type = nt.str; };
      narHash = lib.mkOption { type = nt.nullOr nt.str; default = null; };
    };
  };


# ---------------------------------------------------------------------------- #

  fetchTree.github = nt.submodule {
    name        = "fetchInfo:github";
    description = "`builtins.fetchTree[github]' args";
    options     = {
      type    = lib.mkOption {
        type    = nt.enum ["github"];
        default = "github";
      };
      owner = lib.mkOption { type = nt.str; };
      repo  = lib.mkOption { type = nt.str; };
      rev   = lib.mkOption { type = nt.nullOr nt.str; default = null; };
      ref   = lib.mkOption { type = nt.str; default = "HEAD"; };
    };
  };


# ---------------------------------------------------------------------------- #

  path = nt.submodule {
    name        = "path";
    description = "`builtins.path' args";
    options     = {
      name   = lib.mkOption { type = nt.str; default = "source"; };
      path   = lib.mkOption { type = nt.path; };
      filter = lib.mkOption {
        type    = nt.functionTo ( nt.functionTo nt.bool );
        default = name: type: true;
      };
      recursive = lib.mkOption { type = nt.bool; default = true; };
      sha256    = lib.mkOption { type = nt.nullOr nt.str; default = null; };
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
