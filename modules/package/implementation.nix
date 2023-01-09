# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, floco, ... }: {

# ---------------------------------------------------------------------------- #

  imports = [./trees/implementation.nix ./targets/implementation.nix];

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
        floco.packages.${ident}.${version}.systemSupported
      ) config.pdef.treeInfo;
    };


# ---------------------------------------------------------------------------- #

    inherit (config.pdef) key;

# ---------------------------------------------------------------------------- #

    dist = if config.pdef.ltype == "file" then null else
      import ../../builders/dist.nix {
        inherit lib;
        inherit (pkgs) system;
        pkgsFor = pkgs;
        src     =
          # FIXME: use `config.warnings'
          builtins.trace ( "WARNING: tarball may contain references to Nix " +
                           "store in shebang lines." ) config.built.package;
        pjs = {
          inherit (config.pdef) version;
          name = config.pdef.ident;
        };
      };


# ---------------------------------------------------------------------------- #

    installed = let
      drv = pkgs.stdenv.mkDerivation {
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
            bash -eu "$run_script" -PBi preinstall;
            case "$( jq -r '.scripts.install // null' ./package.json; )" in
              null)
                _pjs_backup="$( <package.json; )";
                echo "$_pjs_backup"|jq '.scripts+={
                  install: "node-gyp rebuild"
                }' >package.json;
                bash -eu "$run_script" -PBi preinstall install postinstall;
                echo "$_pjs_backup" >package.json;
              ;;
              *)
                bash -eu "$run_script" -PBi preinstall install postinstall;
              ;;
            esac
          else
            bash -eu "$run_script" -PBi preinstall install postinstall;
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
      warn = x: let
        warns = map ( m: "WARNING: ${m}" ) config.warnings;
        msg   = builtins.concatStringsSep "\n" warns;
      in if config.warnings == [] then x else builtins.trace msg x;
    in if ! config.pdef.lifecycle.install then config.built.package else
       warn drv;


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
      buildCommand      = ''
        runHook preInstall;

        mkdir -p "$out/lib/node_modules/$IDENT";

        if [[ -n "$NMTREE" ]]; then
          cp -pr --reflink=auto --                         \
             "$NMTREE/node_modules"                        \
             "$out/lib/node_modules/$IDENT/node_modules";
        fi

        bash -eu "$install_module" "$src" "$out/lib/node_modules";

        if [[ -d "$out/lib/node_modules/.bin" ]]; then
          mkdir -p "$out/bin";
          for s in "$out/lib/node_modules/.bin/"*; do
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
