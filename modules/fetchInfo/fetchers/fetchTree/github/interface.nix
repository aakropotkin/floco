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

  fetchTree.github = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[github]` args";
    type        = nt.deferredModuleWith {
      staticModules = [
        ( { ... }: {
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
