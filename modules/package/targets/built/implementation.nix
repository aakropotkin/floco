# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

  cfg = config.built;

in {

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    built.enable = lib.mkDefault config.pdef.lifecycle.build;

    built.tree = lib.mkDefault (
      if cfg.enable then config.trees.dev else null
    );

    built.package = let
      drv = pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-built";
        inherit (config.pdef) version;
        inherit (cfg) copyTree scripts;
        run_script        = ../../../../setup/run-script.sh;
        install_module    = ../../../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        NMTREE            = cfg.tree;
        src               = config.source;
        nativeBuildInputs = let
          maybeLint =
            if ( config.lint == null )                ||
               ( ! cfg.dependsOnLint )                ||
               config.preferMultipleOutputDerivations
            then []
            else [config.lint];
        in [pkgs.jq] ++ maybeLint;
        buildInputs = [pkgs.nodejs-14_x];
        dontUpdateAutotoolsGnuConfigScripts = true;
        configurePhase = ''
          runHook preConfigure;

          export PATH="$PATH:$PWD/node_modules/.bin";
          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";
          if [[ -n "$NMTREE" ]]; then
            if [[ "''${copyTree:-0}" != 1 ]]; then
              ln -s "$NMTREE/node_modules" ./node_modules;
            else
              cp -r --reflink=auto -- "$NMTREE/node_modules" ./node_modules;
              chmod -R +w ./node_modules;
            fi
          fi

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          bash -eu "$run_script" -PBi $scripts;

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
          bash -eu "$install_module" -SLt . "$out";

          runHook postInstall;
        '';
        dontStrip = true;
      };
      warn = x: let
        warns = map ( m: "WARNING: ${m}" ) cfg.warnings;
        msg   = builtins.concatStringsSep "\n" warns;
      in if cfg.warnings == [] then x else builtins.trace msg x;
      withOv = assert cfg.override != null -> cfg.overrideAttrs == null;
        if cfg.override != null then drv.override cfg.override else
        if cfg.overrideAttrs != null
        then drv.overrideAttrs cfg.overrideAttrs
        else drv;
    #in lib.mkDefault ( warn withOv );
    in lib.mkDefault ( if cfg.enable then warn drv else config.source );


# ---------------------------------------------------------------------------- #

  }; # End `config'

# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
