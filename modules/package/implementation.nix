# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, flocoPackages, ... }: {

# ---------------------------------------------------------------------------- #

  config = builtins.mapAttrs ( _: lib.mkDefault ) {

# ---------------------------------------------------------------------------- #

    checkSystemSupport = lib.checkSystemSupportFor config.pdef;
    systemSupported    = config.checkSystemSupport { inherit (pkgs) stdenv; };


# ---------------------------------------------------------------------------- #

    trees = lib.mkIf ( config.pdef.treeInfo != null ) {
      supported = lib.filterAttrs ( k: v: let
        ident   = dirOf v.key;
        version = baseNameOf v.key;
      in ( ! v.optional ) ||
        flocoPackages.packages.${ident}.${version}.systemSupported
      ) config.pdef.treeInfo;
    };


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
        NMTREE            = config.trees.build or config.trees.dev;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
        dontUpdateAutotoolsGnuConfigScripts = true;
        configurePhase    = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";
          if [[ -n "$NMTREE" ]]; then
            ln -s "$NMTREE/node_modules" ./node_modules;
          fi

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          bash -eu "$run_script" -Pi prebuild build postbuild prepublish;

          runHook postBuild;
        '';
        # TODO: make `dist' tarball
        installPhase = ''
          runHook preInstall;

          rm -f ./package-lock.json;
          if [[ -L ./node_modules ]]; then
            rm ./node_modules;
          elif [[ -d ./node_modules ]]; then
            rm -rf ./node_modules;
          fi
          bash -eu "$install_module" -SLt . "$out";

          runHook postInstall;
        '';
        dontStrip = true;
      };


# ---------------------------------------------------------------------------- #

    installed = if ! config.pdef.lifecycle.install then config.built else
      pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-installed";
        inherit (config.pdef) version;
        run_script        = ../../setup/run-script.sh;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        NMTREE            = config.trees.install or config.trees.prod;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
        configurePhase    = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";
          if [[ -n "$NMTREE" ]]; then
            ln -s "$NMTREE/node_modules" ./node_modules;
          fi

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          if [[ -r ./binding.gyp ]]; then
            bash -eu "$run_script" -Pi preinstall;
            case "$( jq -r '.scripts.install // null' ./package.json; )" in
              null)
                _pjs_backup="$( <package.json; )";
                echo "$_pjs_backup"|jq '.scripts+={
                  install: "node-gyp rebuild"
                }' >package.json;
                bash -eu "$run_script" -Pi preinstall install postinstall;
                echo "$_pjs_backup" >package.json;
              ;;
              *)
                bash -eu "$run_script" -Pi preinstall install postinstall;
              ;;
            esac
          else
            bash -eu "$run_script" -Pi preinstall install postinstall;
          fi

          runHook postBuild;
        '';
        installPhase = ''
          runHook preInstall;

          if [[ -L ./node_modules ]]; then
            rm ./node_modules;
          elif [[ -d ./node_modules ]]; then
            rm -rf ./node_modules;
          fi

          # TODO: run `dist' routines before patching shebangs.
          export HOST_PATH;
          bash -eu "$install_module" -Lst . "$out";

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
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
        phases            = ["unpackPhase" "installPhase"];
        # TODO: adhere to `files' or `.{npm,git}ignore'
        installPhase = ''
          runHook preInstall;

          rm -f ./package-lock.json;
          if [[ -L ./node_modules ]]; then
            rm ./node_modules;
          elif [[ -d ./node_modules ]]; then
            rm -rf ./node_modules;
          fi

          export HOST_PATH;
          bash -eu "$install_module" -Lst . "$out";

          runHook postInstall;
        '';
        preferLocalBuild = true;
        allowSubstitutes =
          ( builtins.currentSystem or "unknown" ) != pkgs.system;
        dontStrip = true;
      };


# ---------------------------------------------------------------------------- #

    global = pkgs.stdenv.mkDerivation {
      pname = baseNameOf config.pdef.ident;
      inherit (config.pdef) version;
      install_module    = ../../setup/install-module.sh;
      IDENT             = config.pdef.ident;
      NMTREE            = config.trees.prod;
      src               = config.prepared;
      nativeBuildInputs = [pkgs.jq];
      buildInputs       = [pkgs.nodejs-14_x];
      unpackPhase       = ":";
      dontPatch         = true;
      dontConfigure     = true;
      dontBuild         = true;
      dontStrip         = true;
      dontPatchShebangs = true;  # XXX: this was already done for `prepare'
      installPhase      = ''
        runHook preInstall;

        set -eu;
        set -o pipefail;

        mkdir -p "$out/node_modules/$IDENT";

        if [[ -n "$NMTREE" ]]; then
          cp -pr --reflink=auto -- "$NMTREE/node_modules"                    \
                                   "$out/node_modules/$IDENT/node_modules";
        fi

        bash -eu "$install_module" "$src" "$out/node_modules";

        if [[ -d "$out/node_modules/.bin" ]]; then
          mkdir -p "$out/bin";
          for s in "$out/node_modules/.bin/"*; do
            ln -Lsr "$s" "$out/bin/''${s##*/}";
          done
        fi

        runHook postInstall;
      '';
    };


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
