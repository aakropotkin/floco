# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, floco, pkgs, ... }: let

# ---------------------------------------------------------------------------- #

  nt  = lib.types;
  cfg = config.installed;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/installed/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.installed = lib.mkOption {
    type = nt.submodule { imports = [floco.records.target]; };
  };


# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    installed.enable = lib.mkDefault config.pdef.lifecycle.install;

    installed.scripts = lib.mkDefault ["preinstall" "install" "postinstall"];

    installed.tree = lib.mkDefault (
      if cfg.enable then config.trees.prod else null
    );

    installed.package = let
      drv = lib.makeOverridable pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-installed";
        inherit (config.pdef) version;
        inherit (cfg) copyTree scripts;
        run_script        = ../../../../setup/run-script.sh;
        install_module    = ../../../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        NMTREE            = cfg.tree;
        src               = config.built.package;
        nativeBuildInputs = let
          maybeTest =
            if ( config.test == null )                ||
               ( ! cfg.dependsOnTest )                ||
               config.preferMultipleOutputDerivations
            then []
            else [config.test];
          maybeXcbuild = if pkgs.stdenv.isDarwin then [pkgs.xcbuild] else [];
        in [
          pkgs.jq
          pkgs.nodejs-14_x.pkgs.node-gyp
          pkgs.nodejs-14_x.python
        ] ++ maybeXcbuild ++ maybeTest ++ cfg.extraNativeBuildInputs;
        buildInputs = [pkgs.nodejs-14_x] ++ cfg.extraBuildInputs;
        configurePhase = ''
          runHook preConfigure;

          set -eu;
          set -o pipefail;
          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";
          if [[ -n "''${NMTREE:-}" ]]; then
            if [[ "''${copyTree:-0}" != 1 ]]; then
              ln -s "$NMTREE/node_modules" ./node_modules;
            else
              cp -r --reflink=auto -T -- "$NMTREE/node_modules" ./node_modules;
              chmod -R +w ./node_modules;
            fi
          fi

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          set -eu;
          set -o pipefail;
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

          rm -f ./package-lock.json;
          if [[ -L ./node_modules ]]; then
            rm ./node_modules;
          elif [[ -d ./node_modules ]]; then
            rm -rf ./node_modules;
          fi

          export HOST_PATH;
          bash -eu "$install_module" -SLt . "$out";

          runHook postInstall;
        '';
      };
      warn = x: let
        warns = map ( m: "WARNING: ${m}" ) cfg.warnings;
        msg   = builtins.concatStringsSep "\n" warns;
      in if cfg.warnings == [] then x else builtins.trace msg x;
      withOv = if cfg.overrideAttrs == null then drv else
               drv.overrideAttrs cfg.overrideAttrs;
    in lib.mkDefault (
      if cfg.enable then warn withOv else config.built.package
    );


# ---------------------------------------------------------------------------- #

  }; # End `config'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
