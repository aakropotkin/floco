# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pdef, pkgs, nodePackage, ... }: let

# ---------------------------------------------------------------------------- #

  nt  = lib.types;
  cfg = config.built;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/built/implementation.nix";

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    built.enable = lib.mkDefault pdef.lifecycle.build;

    built.scripts = lib.mkDefault ["prebuild" "build" "postbuild" "prepublish"];

    built.tree = lib.mkDefault (
      if cfg.enable then config.trees.dev else null
    );

    built.package = let
      drv = lib.makeOverridable pkgs.stdenv.mkDerivation ( {
        pname = "${baseNameOf pdef.ident}-built";
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
        src               = config.source;
        nativeBuildInputs = let
          maybeLint =
            if ( config.lint == null )                ||
               ( ! cfg.dependsOnLint )                ||
               config.preferMultipleOutputDerivations
            then []
            else [config.lint];
        in [
          pkgs.jq
          pkgs.floco-hooks
        ] ++ maybeLint ++ cfg.extraNativeBuildInputs;
        buildInputs = [nodePackage] ++ cfg.extraBuildInputs;
        dontUpdateAutotoolsGnuConfigScripts = true;
        configurePhase = ''
          runHook preConfigure;

          export JQ="$( command -v jq; )";
          export NODEJS="$( command -v node; )";

          runHook postConfigure;
        '';
        buildPhase = ''
          runHook preBuild;

          runPjsScripts -i $scripts;

          runHook postBuild;
        '';
        installPhase = ''
          runHook preInstall;

          cleanupNmDir;

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
