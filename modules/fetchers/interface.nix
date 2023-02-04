# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/interface.nix";

# ---------------------------------------------------------------------------- #

  options.fetchers = lib.mkOption {
    description = lib.mdDoc ''
      Fetcher abstractions associated with various forms of inputs and
      evaluation rules.
    '';
    type = nt.submoduleWith {
      modules = [
        ( { ... }: {

          _file = "<floco>/fetchers/interface.nix";

          config._module.args.name = "fetchers";

          imports = [
            ./path/interface.nix
            ./fetchTree/interface.nix
            ./fetchTarballDrv/interface.nix
            ./composed/interface.nix
          ];

          options.pure = lib.mkOption {
            description = lib.mdDoc ''
              Whether fetchers are restricted to pure evaluations.
              Impure fetchers often autofill missing `sha256`, `narHash`, `rev`,
              and other fields which allow later runs to refetch
              resources purely.
            '';
            type    = nt.bool;
            default = ! ( builtins ? currentSystem );
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
