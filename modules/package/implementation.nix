# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, pkgs          ? config._module.arg.pkgs
, flocoPackages ? config._module.args.flocoPackages
, ...
}: {

# ---------------------------------------------------------------------------- #

  config = builtins.mapAttrs ( _: lib.mkDefault ) {

# ---------------------------------------------------------------------------- #

    checkSystemSupport = {
      stdenv   ? throw "checkSystemSupport: You must pass an arg"
    , platform ? stdenv.hostPlatform
    , system   ? platform.system
    }: let
      m = builtins.match "(.*)-([^-]+)" system;
      archPart = builtins.head m;
      archOk = ( builtins.elem "*" config.sysInfo.cpu ) ||
               ( builtins.elem archPart config.sysInfo.cpu );
      osPart = builtins.elemAt m 1;
      osOk = ( builtins.elem "*" config.sysInfo.os ) ||
               ( builtins.elem osPart config.sysInfo.os );
    in archOk && osOk;

# ---------------------------------------------------------------------------- #

    supportedTree = lib.mkIf ( config.pdef.treeInfo != null ) (
      lib.filterAttrs ( k: v:
        ( ! v.optional ) ||
        ( config.checkSystemSupport
      ) config.pdef.treeInfo
    ) );


# ---------------------------------------------------------------------------- #

    inherit (config.pdef) key;
    source = config.pdef.sourceInfo.outPath;

# ---------------------------------------------------------------------------- #

    built = if ! config.pdef.lifecycle.build then config.source else
      pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-built";
        inherit (config.pdef) version;
        run_script        = ../../setup/run-script.sh;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
        configurePhase    = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";

          runHook postConfigure;
        '';
        # TODO: installNodeModules
        buildPhase = ''
          runHook preBuild;

          echo "TODO: install node_modules/" >&2;
          bash -eu "$run_script" -Pi prebuild build postbuild prepublish;

          runHook postBuild;
        '';
        installPhase = ''
          runHook preInstall;

          rm -rf ./node_modules;
          bash -eu "$install_module" -PSLt . "$out";

          runHook postInstall;
        '';
      };


# ---------------------------------------------------------------------------- #

    installed = if ! config.pdef.lifecycle.install then config.built else
      pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-installed";
        inherit (config.pdef) version;
        run_script        = ../../setup/run-script.sh;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
        configurePhase    = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";

          runHook postConfigure;
        '';
        # TODO: installNodeModules
        # TODO: fallback to `node-gyp rebuild'
        buildPhase = ''
          runHook preBuild;

          echo "TODO: install node_modules/" >&2;
          bash -eu "$run_script" -Pi preinstall install postinstall;
          echo "TODO: fallback node-gyp rebuild" >&2;

          runHook postBuild;
        '';
        installPhase = ''
          runHook preInstall;

          rm -rf ./node_modules;
          bash -eu "$install_module" -PSLt . "$out";

          runHook postInstall;
        '';
      };


# ---------------------------------------------------------------------------- #

    prepared = if config.installed != config.source then config.installed else
      pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-prepared";
        inherit (config.pdef) version;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq pkgs.git];
        buildInputs       = [pkgs.nodejs-14_x];
        configurePhase    = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";

          runHook postConfigure;
        '';
        dontBuild = true;
        installPhase = ''
          runHook preInstall;

          rm -rf ./node_modules ./package-lock.json;
          find . -type f -name '.npmignore'                  \
                 -execdir mv ./.npmignore ./.gitignore \; ;
          if [[ ! -d .git ]]; then
            git init;
          fi
          git clean -Xfd;
          rm -rf .git;
          bash -eu "$install_module" -PSLt . "$out";

          runHook postInstall;
        '';
        preferLocalBuild = true;
        allowSubstitutes =
          ( builtins.currentSystem or "unknown" ) != pkgs.system;
      };


# ---------------------------------------------------------------------------- #

    # FIXME
    global = pkgs.emptyDirectory;


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
