# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../fetchInfo/types.nix;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  imports = [
    ./tarball/interface.nix
    ./file/interface.nix
    ./git/interface.nix
    ./github/interface.nix
  ];


# ---------------------------------------------------------------------------- #

  #options.fetchTree = lib.mkOption {
  #  description = lib.mdDoc ''
  #    `builtins.fetchTree` subtypes.
  #  '';
  #  type = nt.submoduleWith {
  #    modules = [
  #      ( { ... }: {
  #        imports = [
  #          ./file/interface.nix
  #          ./tarball/interface.nix
  #          ./git/interface.nix
  #          ./github/interface.nix
  #        ];

  #        options.any = lib.mkOption {
  #          description = lib.mdDoc "`builtins.fetchTree` args";
  #          type        = nt.deferredModuleWith {
  #            staticModules = [
  #              ( { ... }: {
  #                options.type = lib.mkOption {
  #                  type = nt.enum ["git" "github" "file" "tarball"];
  #                };
  #                options.narHash = lib.mkOption {
  #                  type    = nt.nullOr ft.narHash;
  #                  default = null;
  #                };
  #              } )
  #            ];
  #          };
  #        };  # End `options.fetchTree.any'

  #      } )  # End module
  #    ];
  #  };
  #};


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
