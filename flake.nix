# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description = "Yet another Nix+Node.js framework";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, ... } @ inputs: let

# ---------------------------------------------------------------------------- #

    inherit (( import ./lib { inherit (nixpkgs) lib; } ).libfloco)
      eachSupportedSystemMap
    ;


# ---------------------------------------------------------------------------- #

    overlays.deps    = final: prev: {};
    overlays.floco   = import ./overlay.nix;
    overlays.default = nixpkgs.lib.composeExtensions overlays.deps
                                                     overlays.floco;


# ---------------------------------------------------------------------------- #

    nixosModules.default = nixosModules.floco;
    nixosModules.floco   = import ./modules/top;

    nixosModules.plockToPdefs = { lib, lockDir, basedir, ... }: {
      imports = [./modules/top];
      config._module.args.basedir = lib.mkDefault lockDir;
      config._module.args.lockDir = lib.mkDefault basedir;
      options.floco = lib.mkOption {
        type = lib.types.submoduleWith {
          shorthandOnlyDefinesConfig = false;
          modules = [
            ./modules/plockToPdefs
            {
              config._module.args.basedir = basedir;
              config.lockDir = lib.mkDefault lockDir;
            }
          ];
        };
      };
    };


    # Use `nixpkgs#fetchzip' instead of `builtins.fetchTree' for tarballs.
    #
    # This changes the caching behavior of tarballs, particularly when used in
    # combination with a remote binary cache.
    #
    # This module is a recommended addition to `nixosModules.floco' for driving
    # builds in a CI/CD context with a remote cache, because it skips fetching
    # tarballs that are inputs to existing cached artifacts.
    # Without this module, `builtins.fetchTree' will fetch any tarballs which
    # are an input to any requested artifact, regardless of whether or not that
    # artifact is already in the remote store.
    # 
    # This module may not be desireable for local development on builds which
    # may fail, because `nix' will not save inputs to failed results in its
    # store, causing them to be refetched repeatedly until the build succeeds.
    nixosModules.useFetchZip = import ./modules/configs/use-fetchzip.nix;


# ---------------------------------------------------------------------------- #

  in {  # Begin `outputs'

# ---------------------------------------------------------------------------- #

    lib = import ./lib { inherit (nixpkgs) lib; };

# ---------------------------------------------------------------------------- #

    inherit overlays nixosModules;

# ---------------------------------------------------------------------------- #

    packages = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
    in {
      inherit (pkgsFor)
        floco
        floco-nix
        floco-utils
        floco-hooks
        floco-updaters
        treeFor
        semver
        pacote
        arborist
      ;
      default = pkgsFor.floco;
    } );


# ---------------------------------------------------------------------------- #

    apps = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
      stripNL  = s: let
        m = builtins.match "\n*\([^\n]*.*[^\n]\)\n*" s;
      in if m == null then m else builtins.head m;
    in {

      fromPlock = {
        type    = "app";
        program = let
          msg = stripNL ''
            floco#fromPlock: The \`fromPlock' routine is deprecated.
              Use \`floco -- translate ARGS...' or
              `nix run github:aakropotkin/floco -- translate ARGS...` instead.
          '';
        in builtins.trace msg "${pkgsFor.floco-updaters}/bin/npm-plock.sh";
      };

      fromRegistry = {
        type    = "app";
        program = let
          msg = stripNL ''
            floco#fromPlock: The \`fromRegistry' routine is deprecated.
              Use \`floco -- translate ARGS...' or
              `nix run github:aakropotkin/floco -- translate ARGS...` instead.
          '';
        in builtins.trace msg "${pkgsFor.floco-updaters}/bin/from-registry.sh";
      };

    } );


# ---------------------------------------------------------------------------- #

    templates = let
      basic = {
        description = "a legacy style `default.nix' for a local project.";
        path        = ./templates/basic;
        welcomeText = ''
          Initialize/update your project by running:

          nix run github:aakropotkin/floco -- translate -pt;


          Build with:

          nix build -f ./. -L global;


          Be sure to read `foverrides.nix' to customize your build.
          If you do not require this file feel free to delete it.
        '';
      };
    in {
      inherit basic;
      default  = basic;
      registry = {
        description = "a legacy style `default.nix' for a registry package.";
        path        = ./templates/registry;
        welcomeText = ''
          Initialize/update your package by running:

          nix run github:aakropotkin/floco -- translate -pt <IDENT>@<VERSION>;

          echo '{ ident = "<IDENT>"; version = "<VERSION>"; }' > info.nix;


          Build with:

          nix build -f ./. -L;


          If you don't require `foverrides.nix', feel free to remove it.
        '';
      };
    };


# ---------------------------------------------------------------------------- #

    # A shorthand for accessing `nixpkgs' with `overlays.floco' applied.
    # This is equivalent to `nixpkgs.legacyPackages', but intentionally uses a
    # different name to indicate that it is an EXTENDED `nixpkgs' rather
    # than the subset of packages defined in `overlays.floco'.
    pkgsFor = let
      bySystem = eachSupportedSystemMap ( system:
        nixpkgs.legacyPackages.${system}.extend overlays.default
      );
    in bySystem // {
      __functor = pf: system:
        pf.${system} or (
          throw "floco#pkgsFor: Unsupported system: ${system}"
        );
    };


# ---------------------------------------------------------------------------- #

    # Convenience function that evaluates the `floco' module system on a
    # singleton or list of modules/directories.
    #
    # This has a flexible call style that allows you to indicate `system'.
    # To be explicit use either:
    #   runFloco.<system> <module(s)>
    #   runFloco "<system>" <module(s)>
    # To omit system intentionally:
    #   runFloco.unknown <module(s)>
    #   runFloco "unknown" <module(s)>
    # Or to use the current system as the default, simply:
    #   runFloco <module(s)>
    #
    # In `pure' evaluation mode, attempts to reference `builtins.currentSystem'
    # will fall back to "unknown", meaning you will only be able to use `lib'
    # routines and parts of the module system that do not reference `pkgs'.
    #
    # This is recommended as a convenience routine for interactive use on the
    # CLI, and is explicitly NOT recommended for use scripts or CI automation.
    # For non-interactive use, please use `lib.evalModules' directly, and be
    # explicit about `system', module paths, and handling of JSON files
    # ( use `lib.modules.importJSON' or `lib.libfloco.processImports[Floco]' ).
    inherit (( import ./lib { inherit (nixpkgs) lib; } ).libfloco) runFloco;


# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
