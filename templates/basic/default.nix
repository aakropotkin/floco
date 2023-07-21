# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco        ? builtins.getFlake "github:aakropotkin/floco"
, lib          ? floco.lib
, system       ? builtins.currentSystem
, extraModules ? []
}: let

# ---------------------------------------------------------------------------- #

  pjs = let
    msg = "default.nix: Expected to find `package.json' to lookup " +
          "package name/version, but no such file exists at: " +
          ( toString ./package.json );
  in if builtins.pathExists ./package.json then lib.importJSON ./package.json
                                           else throw msg;
  ident = pjs.name;
  inherit (pjs) version;


# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      floco.nixosModules.floco
      { config.floco.settings = { inherit system; basedir = ./.; }; }
      ./floco-cfg.nix
    ] ++ ( lib.toList extraModules );
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
  built = pkg.built.package;

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
