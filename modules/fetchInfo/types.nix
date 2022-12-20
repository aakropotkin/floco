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

  fetchTree.tarball.unlocked = lib.mkOptionType {
    name        = "fetchInfo:tarball[unlocked]";
    description = "impure `builtins.fetchTree[tarball]' args";
    check       = v:
      ( v ? url ) &&
      ( ( v.type or null ) == "tarball" ) &&
      ( ! ( v ? narHash ) );
    getSubOptions = prefix: prefix ++ ["type" "url"];
  };

  fetchTree.tarball.locked = lib.mkOptionType {
    name        = "fetchInfo:tarball[locked]";
    description = "pure `builtins.fetchTree[tarball]' args";
    check       = v:
      ( v ? url ) &&
      ( ( v.type or null ) == "tarball" ) &&
      ( v ? narHash );
    getSubOptions = prefix: prefix ++ ["type" "url" "narHash"];
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
