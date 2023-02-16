# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/env/implementation.nix";

# ---------------------------------------------------------------------------- #

  config._module.args.pkgs = lib.mkOptionDefault (
    config.inputs.nixpkgs.flake.legacyPackages.${config.settings.system}
  );

  config.env.pkgs = lib.mkOptionDefault ( pkgs.extend ../../overlay.nix );

  config.env.lib = lib.mkOptionDefault (
    if lib ? libfloco then lib else lib.extend ../../lib/overlay.lib.nix
  );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
