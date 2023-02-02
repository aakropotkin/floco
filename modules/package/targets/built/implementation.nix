# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, floco, pkgs, ... }: let

  nt  = lib.types;
  cfg = config.built;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/built/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.built = lib.mkOption {
    type = nt.submodule { imports = [floco.records.target]; };
  };


# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    built.enable = lib.mkDefault config.pdef.lifecycle.build;

    built.scripts = lib.mkDefault ["prebuild" "build" "postbuild" "prepublish"];

    built.tree = lib.mkDefault (
      if cfg.enable then config.trees.dev else null
    );

    built.package = let
      drv = lib.makeOverridable pkgs.stdenv.mkDerivation ( {
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
        in [pkgs.jq] ++ maybeLint ++ cfg.extraNativeBuildInputs;
        buildInputs = [pkgs.nodejs-14_x] ++ cfg.extraBuildInputs;
        dontUpdateAutotoolsGnuConfigScripts = true;
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
      } // cfg.override );
      warn = x: let
        warns = map ( m: "WARNING: ${m}" ) cfg.warnings;
        msg   = builtins.concatStringsSep "\n" warns;
      in if cfg.warnings == [] then x else builtins.trace msg x;
      withOv = if cfg.overrideAttrs == null then drv else
               drv.overrideAttrs cfg.overrideAttrs;
    in lib.mkDefault ( if cfg.enable then warn withOv else config.source );


# ---------------------------------------------------------------------------- #

  }; # End `config'

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
