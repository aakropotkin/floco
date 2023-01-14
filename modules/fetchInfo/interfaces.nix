# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
# By default we provide types used by `builtins.fetchTree', and `builtins.path'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ./types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

  fetchInfo = lib.mkOption {
    description = lib.mdDoc ''
      Arguments passed to fetcher.
      By default any `builtins.fetchTree` or `builtins.path` argset is
      supported, and the correct fetcher can be inferred from these values.

      If set to `null`, `sourceInfo` must be set explicitly.
    '';
    type = ( nt.submodule {
      freeformType =
        nt.attrsOf ( nt.nullOr ( nt.oneOf [nt.str nt.path nt.int nt.bool] ) );
    } ) // { inherit (ft.fetchInfo) check; };
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
