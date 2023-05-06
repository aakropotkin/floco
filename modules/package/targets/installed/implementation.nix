# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pdef, pkgs, ... }: let

# ---------------------------------------------------------------------------- #

  nt  = lib.types;
  cfg = config.installed;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/installed/implementation.nix";

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    installed.enable = lib.mkDefault pdef.lifecycle.install;

    installed.scripts = lib.mkDefault ["preinstall" "install" "postinstall"];

    installed.tree = lib.mkDefault (
      if cfg.enable then config.trees.prod else null
    );

    installed.package = let
      drv = lib.makeOverridable pkgs.stdenv.mkDerivation ( {
        pname = "${baseNameOf pdef.ident}-installed";
        inherit (pdef) version;
        inherit (cfg) copyTree scripts;
        builder = builtins.path {
          path      = ../../../../builders/floco-builder.sh;
          recursive = false;
        };
        install_module = builtins.path {
          path      = ../../../../setup/install-module.sh;
          recursive = false;
        };
        IDENT             = pdef.ident;
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
          pkgs.floco-hooks
        ] ++ maybeXcbuild ++ maybeTest ++ cfg.extraNativeBuildInputs;
        buildInputs = [pkgs.nodejs-14_x] ++ cfg.extraBuildInputs;
        configurePhase = ''
          runHook preConfigure;

          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          if [[ -r ./binding.gyp ]]; then
            runPjsScript -i preinstall;
            case "$( jq -r '.scripts.install // null' ./package.json; )" in
              null)
                _pjs_backup="$( <package.json; )";
                echo "$_pjs_backup"|jq '.scripts+={
                  install: "node-gyp rebuild"
                }' >package.json;
                runPjsScripts -i preinstall install postinstall;
                echo "$_pjs_backup" >package.json;
              ;;
              *)
                runPjsScripts -i preinstall install postinstall;
              ;;
            esac
          else
            runPjsScripts -i preinstall install postinstall;
          fi

          runHook postBuild;
        '';
        installPhase = ''
          runHook preInstall;

          cleanupNmDir;

          export HOST_PATH;
          bash -eu "$install_module" -SLt . "$out";

          runHook postInstall;
        '';
      } // cfg.override );
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
