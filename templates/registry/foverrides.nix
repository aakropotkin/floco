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
    #
    # Below that segment, you'll see an option to `copyTree' which will cause
    # the `node_modules/' directory to be copied and made writable at when
    # `install' scripts are run.
    # This can help resolve issues with packages such as `esbuild' which
    # modify the contents of their `node_modules/' directory at install time.

    ##installed = { pkgs, ... }: {
    ##  extraBuildInputs = [
    ##    pkgs.pkg-config
    ##  ];
    ##  copyTree = true;
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
