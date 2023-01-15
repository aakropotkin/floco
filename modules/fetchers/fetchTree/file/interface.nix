# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../../fetchInfo/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

  options.fetchTree_file = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[file]` args";
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
