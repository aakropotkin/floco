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

  overrides = { config, ... }: {
    config.floco.packages."@floco/test"."4.2.0" = {
      built.overrideAttrs = prev: {
        buildInputs = prev.buildInputs ++ [
          config.floco.packages."typescript"."4.9.4".global
        ];
      };
    };
  };


  fmod = lib.evalModules {
    modules = [
      "${floco}/modules/top"
      {
        config._module.args.pkgs =
          floco.inputs.nixpkgs.legacyPackages.${system}.extend
            floco.overlays.default;
      }
      # Loads our generated `pdefs.nix' as a "module config".
      ( lib.addPdefs ./pdefs.nix )
      overrides
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
