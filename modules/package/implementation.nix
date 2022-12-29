# ============================================================================ #
#
# Expects `config.pkgdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    inherit (config.pkgdef) key;
    source = config.pkgdef.sourceInfo.outPath;

# ---------------------------------------------------------------------------- #

    built = if ! config.pkgdef.lifecycle.build then config.source else
      config.pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pkgdef.ident}-built";
        inherit (config.pkgdef) version;
        run_script        = ../../setup/run-script.sh;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pkgdef.ident;
        src               = config.source;
        nativeBuildInputs = [config.pkgs.jq];
        buildInputs       = [config.pkgs.nodejs-14_x];
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

    installed = if ! config.pkgdef.lifecycle.install then config.built else
      config.pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pkgdef.ident}-installed";
        inherit (config.pkgdef) version;
        run_script        = ../../setup/run-script.sh;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pkgdef.ident;
        src               = config.source;
        nativeBuildInputs = [config.pkgs.jq];
        buildInputs       = [config.pkgs.nodejs-14_x];
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
      config.pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pkgdef.ident}-prepared";
        inherit (config.pkgdef) version;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pkgdef.ident;
        src               = config.source;
        nativeBuildInputs = [config.pkgs.jq config.pkgs.git];
        buildInputs       = [config.pkgs.nodejs-14_x];
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
          ( builtins.currentSystem or "unknown" ) != config.pkgs.system;
      };


# ---------------------------------------------------------------------------- #

    # FIXME
    global = config.pkgs.emptyDirectory;


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
