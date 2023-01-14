# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../../types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

  fetchTree.file = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[file]` args";
    type        = nt.deferredModuleWith {
      staticModules = [
        ( { ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["file"];
              default = "file";
            };
            url     = lib.mkOption { type = nt.str; };
            narHash = lib.mkOption {
              type    = nt.nullOr ft.narHash;
              default = null;
            };
          };
        } )
      ];
    };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
