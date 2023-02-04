# default.nix
# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco  ? builtins.getFlake ( toString ../../.. )
, lib    ? floco.lib
, system ? builtins.currentSystem
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      floco.nixosModules.floco
      # Loads our generated `pdefs.nix' as a "module config".
      ./pdefs.nix
      ( { config, ... }: {
        config.floco.settings = { inherit system; basedir = ./.; };
        config.floco.packages."@floco/test"."4.2.0".built.extraBuildInputs = [
          config.floco.packages.typescript."4.9.5".global
        ];
      } )
    ];
  };


# ---------------------------------------------------------------------------- #

  # This attrset holds a few derivations related to our package.
  # We'll expose these below to the CLI.
  pkg = fmod.config.floco.packages."@floco/test"."4.2.0";

# ---------------------------------------------------------------------------- #

in {
  inherit (pkg)
    dist      # A tarball form of our built package suitable for publishing
    prepared  # The "prepared" form of our project for use by other Nix builds
    global    # A globally installed form to run our executable
  ;
  # Our project in it's "built" state
  built = pkg.built.package;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
