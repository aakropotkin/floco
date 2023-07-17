# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco        ? builtins.getFlake "github:aakropotkin/floco"
, lib          ? floco.lib
, system       ? builtins.currentSystem
, extraModules ? []
, pkgs         ? import <nixpkgs> {currentSystem = system;}
}: let

# ---------------------------------------------------------------------------- #

  pjs   = lib.importJSON ./package.json;
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
} ) // {
  # ---------------------------------------------------------------------------- #

  # A fast devshell example
  # caches the node_modules tree (hash) providing the following features
  # - blazingly fast
  # - updates only when necessary
  # - updates only what has changes
  #
  devShell = pkgs.mkShell {
    buildInputs = [
      # Use the same configured nodejs for the shell env
      # 'config.floco.settings.nodePackage = pkgs.nodejs-18_x;'
      fmod.config.floco.settings.nodePackage
      # Add more build inputs here as needed
      # ...
    ];

    # This shell hook uses `pkgs.rsync` for superfast node_modules and incremental updates on changes
    #
    # rsync the node_modules folder
    # - way faster than copying everything again, because it only replaces updated files
    # - rsync can be restarted from any point, if failed or aborted mid execution.
    # Options:
    # -a            -> all files recursive, preserve symlinks, etc.
    # --delete      -> removes deleted files
    # --chmod=+ug+w -> make folder writeable by user+group
    #               ->  You can turn this on/off. Depending on your need for write-access to the node_modules folder
    shellHook = ''
      ID=${pkg.built.tree}
      currID=$(cat .floco/.node_modules_id 2> /dev/null)

      mkdir -p .floco
      if [[ "$ID" != "$currID" || ! -d "node_modules"  ]];
      then
        ${pkgs.rsync}/bin/rsync -a --chmod=ug+w  --delete ${pkg.built.tree}/node_modules/ ./node_modules/
        echo -n $ID > .floco/.node_modules_id
        echo "floco ok: node_modules updated"
      fi

      export PATH="$PATH:$(realpath ./node_modules)/.bin"
    '';
  };
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
