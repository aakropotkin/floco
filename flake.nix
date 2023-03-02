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

    supportedSystems = [
      "x86_64-linux"  "aarch64-linux"  "i686-linux" 
      "x86_64-darwin" "aarch64-darwin"
    ];

    eachSupportedSystemMap = f: builtins.foldl' ( acc: system: acc // {
      ${system} = f system;
    } ) {} supportedSystems;


# ---------------------------------------------------------------------------- #

    overlays.floco   = import ./overlay.nix;
    overlays.default = overlays.floco;


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
    in {

      fromPlock = {
        type    = "app";
        program = "${pkgsFor.floco-updaters}/bin/npm-plock.sh";
      };

      fromRegistry = {
        type    = "app";
        program = "${pkgsFor.floco-updaters}/bin/from-registry.sh";
      };

    } );


# ---------------------------------------------------------------------------- #

    templates = let
      basic = {
        description = "a legacy style `default.nix' for a local project.";
        path        = ./templates/basic;
        welcomeText = ''
          Initialize/update your project by running:

          nix run floco#fromPlock -- -pt;


          Build with:

          nix build -f ./. -L global;


          Be sure to read `foverrides.nix' to customize your build.
          If you do not require this file feel free to delete it.
        '';
      };
    in {
      inherit basic;
      default = basic;
      fillPins = {
        description = "Expression for filling missing `pin's in `pdefs.nix'.";
        path        = ./templates/fill-pins;
      };
      registry = {
        description = "a legacy style `default.nix' for a registry package.";
        path        = ./templates/registry;
        welcomeText = ''
          Initialize/update your package by running:

          nix run floco#fromRegistry -- -pt <IDENT>@<VERSION>;

          echo '{ ident = "<IDENT>"; version = "<VERSION>"; }' > info.nix;


          Build with:

          nix build -f ./. -L;


          If you don't require `foverrides.nix', feel free to remove it.
        '';
      };
    };


# ---------------------------------------------------------------------------- #

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

    runFloco = let
      bySystem   = eachSupportedSystemMap forSystem;
      lib        = import ./lib { inherit (nixpkgs) lib; };
      isPathlike = x:
        ( builtins.isPath x ) ||
        ( builtins.isString x ) ||
        ( ( builtins.isAttrs x ) && ( x ? outPath ) );
      isDir = x:
        ( isPathlike x ) &&
        ( builtins.pathExists ( x + "/." ) );
      toCfg = x:
        if builtins.isAttrs x then x else
        if isDir x then {
          _file   = toString x;
          imports = let
            tries = map ( f: x + ( "/" + f ) ) [
              "floco-cfg.nix"  "floco-cfg.json"
              "pdefs.nix"      "pdefs.json"
              "foverrides.nix" "foverrides.json"
            ];
            e  = builtins.filter ( builtins.pathExists ) tries;
            fc = builtins.filter ( f: builtins.elem ( baseNameOf f ) [
              "floco-cfg.nix" "floco-cfg.json"
            ] ) e;
            pc = builtins.filter ( f: builtins.elem ( baseNameOf f ) [
              "pdefs.nix" "pdefs.json"
            ] ) e;
            oc = builtins.filter ( f: builtins.elem ( baseNameOf f ) [
              "foverrides.nix" "foverrides.json"
            ] ) e;
            files = if fc != [] then [( builtins.head fc )] else
                    ( if pc == [] then [] else [( builtins.head pc )] ) ++
                    ( if oc == [] then [] else [( builtins.head oc )] );
          in map ( f:
            if lib.hasSuffix ".json" f then lib.modules.importJSON f else f
          ) files;
        } else if isPathlike x then (
          if lib.hasSuffix ".json" x then lib.modules.importJSON x else x
        ) else x;

      forSystem = system: cfgs: ( lib.evalModules {
        modules = [
          nixosModules.floco
          { config.floco.settings = { inherit system; }; }
        ] ++ ( map toCfg ( lib.toList cfgs ) );
      } ).config.floco;

    in bySystem // {
      __functor = pf: system:
        pf.${system} or (
          throw "floco#runFloco: Unsupported system: ${system}"
        );
    };


# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
