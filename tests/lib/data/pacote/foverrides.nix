# ============================================================================ #
#
# Explicit config and overrides.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  inherit (import ./info.nix) ident version;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  config.floco.packages.${ident}.${version} = let
    cfg = config.floco.packages.${ident}.${version};
  in {  # Begin target package overrides

# ---------------------------------------------------------------------------- #

    # CHANGEME: The following provides an example of adding an input from
    # Nixpkgs to the "install" phase environment.
    # This is useful for linking against libraries when running `node-gyp'
    # and providing other utilities that may be required.

    ##installed = { pkgs, ... }: {
    ##  extraBuildInputs = [
    ##    pkgs.pkgconfig
    ##  ];
    ##};


# ---------------------------------------------------------------------------- #

  };  # End target package overrides


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
