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

    fetchTree.tarball = nt.submodule {
      options = {
        type = lib.mkOption {
          type    = nt.enum ["tarball"];
          default = "tarball";
        };
        url     = lib.mkOption { type = nt.str; };
        narHash = lib.mkOption {
          type    = nt.nullOr types.narHash;
          default = null;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    fetchTree.file = nt.submodule {
      options = {
        type    = lib.mkOption { type = nt.enum ["file"]; default = "file"; };
        url     = lib.mkOption { type = nt.str; };
        narHash = lib.mkOption {
          type    = nt.nullOr types.narHash;
          default = null;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    fetchTree.github = nt.submodule {
      options = {
        type = lib.mkOption {
          type    = nt.enum ["github"];
          default = "github";
        };
        owner   = lib.mkOption { type = nt.str; };
        repo    = lib.mkOption { type = nt.str; };
        rev     = lib.mkOption { type = nt.nullOr nt.str; default = null; };
        ref     = lib.mkOption { type = nt.str; default = "HEAD"; };
        narHash = lib.mkOption {
          type    = nt.nullOr types.narHash;
          default = null;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    fetchTree.git = nt.submodule {
      options = {
        type       = lib.mkOption { type = nt.enum ["git"]; default = "git"; };
        url        = lib.mkOption { type = nt.str; };
        allRefs    = lib.mkOption { type = nt.bool; default = false; };
        shallow    = lib.mkOption { type = nt.bool; default = false; };
        submodules = lib.mkOption { type = nt.bool; default = false; };
        rev        = lib.mkOption { type = nt.nullOr nt.str; default = null; };
        ref        = lib.mkOption { type = nt.str; default = "HEAD"; };
        narHash = lib.mkOption {
          type    = nt.nullOr types.narHash;
          default = null;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    fetchTree.any = nt.oneOf [
      types.fetchTree.tarball
      types.fetchTree.file
      types.fetchTree.github
      types.fetchTree.git
      # TODO:
      #types.fetchTree.path
      #types.fetchTree.mercurial
      #types.fetchTree.gitlab
    ];


# ---------------------------------------------------------------------------- #

    path = nt.submodule {
      options = {
        name   = lib.mkOption { type = nt.str; default = "source"; };
        path   = lib.mkOption { type = nt.path; };
        filter = lib.mkOption {
          type    = nt.functionTo ( nt.functionTo nt.bool );
          default = name: type: true;
        };
        recursive = lib.mkOption { type = nt.bool; default = true; };
        sha256    = lib.mkOption {
          type    = nt.nullOr ( nt.either types.sha256_hash types.sha256_sri );
          default = null;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.oneOf [
      types.fetchTree.tarball
      types.fetchTree.file
      types.fetchTree.github
      types.fetchTree.git
      types.path
    ];


# ---------------------------------------------------------------------------- #

  };

in types


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
