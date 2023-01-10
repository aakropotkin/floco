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

  overrides = { config, ... }: {
    # Removes any `*.nix' files as well as `node_modules/' and
    # `package-lock.json' from the source tree before using them in builds.
    config.floco.packages.${ident}.${version} = let
      cfg = config.floco.packages.${ident}.${version};
    in {
      source = builtins.path {
        name   = "source";
        path   = ./.;
        filter = name: type: let
          bname  = baseNameOf name;
          test   = p: s: ( builtins.match p s ) != null;
          ignore = ["node_modules" "package-lock.json"];
        in ( ! ( builtins.elem bname ignore ) ) &&
           ( ! ( test ".*\\.nix" bname ) );
      };
      # FIXME: This adds a copy of `typescript' to the "build" environment
      # as a globally installed executable.
      # This allows `typescript' to be dropped from your `node_modules/'
      # directory in order to speed up builds.
      # You can remove or modify this block as you see fit.
      built.tree = removeAttrs cfg.trees.dev ["node_modules/typescript"];
      built.overrideAttrs =
        lib.mkIf ( cfg.trees.dev ? "node_modules/typescript" ) ( prev: {
          buildInputs = let
            tsVersion = baseNameOf cfg.trees.dev."node_modules/typescript";
          in prev.buildInputs ++ [
            config.floco.packages."typescript".${tsVersion}.global
          ];
        } );
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
} // ( if ! lib.isDerivaiton pkg.built.package then {} else {
  built    = pkg.built.package;
  devNmDir = pkg.built.tree;
} ) // ( if ! lib.isDerivaiton pkg.lint then {} else {
  inherit (pkg) lint;
} ) // ( if ! lib.isDerivaiton pkg.test then {} else {
  inherit (pkg) test;
} )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
