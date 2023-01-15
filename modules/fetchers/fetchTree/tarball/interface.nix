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

  options.tarball = lib.mkOption {
    description = lib.mdDoc "`builtins.fetchTree[tarball]` args";
    type        = nt.deferredModuleWith {
      staticModules = [
        ( { ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["tarball"];
              default = "tarball";
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