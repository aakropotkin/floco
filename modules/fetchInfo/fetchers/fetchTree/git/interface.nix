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

  fetchTree.git = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[git]` args";
    type        = nt.deferredModuleWith {
      staticModules = [
        ( { ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["git"];
              default = "git";
            };
            url        = lib.mkOption { type = nt.str; };
            allRefs    = lib.mkOption { type = nt.bool; default = false; };
            shallow    = lib.mkOption { type = nt.bool; default = false; };
            submodules = lib.mkOption { type = nt.bool; default = false; };
            rev        = lib.mkOption {
              type    = nt.nullOr nt.str;
              default = null;
            };
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
