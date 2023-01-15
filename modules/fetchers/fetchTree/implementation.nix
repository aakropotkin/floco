# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... } @ _fetchInfo: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  imports = [./tarball/implementation.nix];


# ---------------------------------------------------------------------------- #

  #options.fetchTree = lib.mkOption {
  #  type = nt.submoduleWith {
  #    modules = [
  #      ( { config, ... } @ _fetchTree: {

  #        imports = [
  #          ./file/implementation.nix
  #          ./tarball/implementation.nix
  #          ./git/implementation.nix
  #          ./github/implementation.nix
  #        ];

  #        options.any = lib.mkOption {
  #          type = nt.deferredModuleWith {
  #            staticModules = [
  #              ( { ... }: {
  #                freeformType = let
  #                  mkSub = def: nt.submodule {
  #                    imports = [def];
  #                    config._module.args.pure = _fetchInfo.config.pure;
  #                  };
  #                in nt.oneOf ( map mkSub [
  #                  _fetchTree.config.file
  #                  _fetchTree.config.tarball
  #                  _fetchTree.config.git
  #                  _fetchTree.config.github
  #                ] );
  #              } )
  #            ];
  #          };
  #          default = {};
  #        };

  #        config._module.args.pure = _fetchInfo.config.pure;
  #      } )
  #    ];
  #  };  # End `options.fetchInfo.type'

  #  default = {};

  #};  # End `options.fetchTree'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
