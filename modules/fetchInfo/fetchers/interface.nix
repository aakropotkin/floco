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

  imports = [./path/interface.nix];

  options.pure = lib.mkOption {
    description = lib.mdDoc ''
      Whether fetchers are restricted to pure evaluations.
      Impure fetchers often autofill missing `sha256`, `narHash`, `rev`, and
      other fields which allow later runs to refetch resources purely.
    '';
    type    = nt.bool;
    default = ! ( builtins ? currentSystem );
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
