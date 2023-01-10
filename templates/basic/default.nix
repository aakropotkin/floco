# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco  ? builtins.getFlake "github:aakropotkin/floco"
, lib    ? floco.lib
, system ? builtins.currentSystem
}: let

# ---------------------------------------------------------------------------- #

  pjs   = lib.importJSON ./package.json;
  ident = pjs.name;
  inherit (pjs) version;


# ---------------------------------------------------------------------------- #

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
      # Explicit config
      ./foverrides.nix
    ];
  };


# ---------------------------------------------------------------------------- #

  # This attrset holds a few derivations related to our package.
  # We'll expose these below to the CLI.
  pkg = fmod.config.floco.packages.${ident}.${version};

# ---------------------------------------------------------------------------- #

in {
  inherit (pkg)
    dist      # A tarball form of our built package suitable for publishing
    prepared  # The "prepared" form of our project for use by other Nix builds
    global    # A globally installed form to run our executable
  ;
  prodNmDir = pkg.trees.prod;
  # Our project in it's "built" state
} // ( if ! lib.isDerivation pkg.built.package then {} else {
  built    = pkg.built.package;
  devNmDir = pkg.built.tree;
} ) // ( if ! lib.isDerivation pkg.lint then {} else {
  inherit (pkg) lint;
} ) // ( if ! lib.isDerivation pkg.test then {} else {
  inherit (pkg) test;
} )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
