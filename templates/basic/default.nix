# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco   ? builtins.getFlake "github:aakropotkin/floco"
, nixpkgs ? floco.inputs.nixpkgs
, lib     ? floco.lib
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}.extend floco.overlays.default
}: let

# ---------------------------------------------------------------------------- #

  pjs   = lib.importJSON ./package.json;
  ident = pjs.name;
  inherit (pjs) version;


# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      floco.nixosModules.floco
      { config.floco.settings = { inherit system; }; }
      ./floco-cfg.nix
    ];
  };


# ---------------------------------------------------------------------------- #

  # This attrset holds a few derivations related to our package.
  # We'll expose these below to the CLI.
  pkg = fmod.config.floco.packages.${ident}.${version};

# ---------------------------------------------------------------------------- #

in {

  genPdefs = pkgsFor.writeShellApplication {
    name          = "genPdefs";
    runtimeInputs = [pkgsFor.floco-updaters];
    text          = let
      pwd = toString ./.;
    in ''
      export PINS=:;
      export TREE=:;
      exec npm-plock.sh -l ${pwd} "$@";
    '';
  };

  inherit (pkg)
    dist      # A tarball form of our built package suitable for publishing
    prepared  # The "prepared" form of our project for use by other Nix builds
    global    # A globally installed form to run our executable
  ;

  # The base `node_modules/' tree used for post-dist phases.
  # See "NOTE" below about `NMTREE' targets.
  prodNmDir = pkg.trees.prod;

} // ( if ! pkg.built.enable then {} else {

  # The base `node_modules/' tree used for pre-dist phases.
  # NOTE: If you explicitly modify `pkgs.*.NMTREE' options then this tree may
  # differ from what's used during builds.
  # To get the "real" tree you can always use an invocation such as:
  #   nix build -f ./. built.NMTREE;
  devNmDir = pkg.built.tree;

  # Our project in it's "built" state
  built    = pkg.built.package;

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
