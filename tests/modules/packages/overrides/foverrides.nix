# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: {

# ---------------------------------------------------------------------------- #

  config.floco.packages."@floco/test"."4.2.0" = let
    cfg       = config.floco.packages."@floco/test"."4.2.0";
    tsVersion = baseNameOf cfg.pdef.treeInfo."node_modules/typescript".key;
  in {

    source = builtins.path {
      name   = "source";
      path   = ./.;
      filter = name: type:
        builtins.elem ( baseNameOf name ) ["bin.js" "index.ts" "package.json"];
    };

    built.tree = cfg.trees.dev.overrideAttrs ( prev: {
      treeInfo = removeAttrs prev.treeInfo ["node_modules/typescript"];
    } );

    built.extraBuildInputs = [
      config.floco.packages.typescript.${tsVersion}.global
    ];

    built.override = {
      preBuild = ''
        ls -R ./node_modules >&2;
      '';
    };

    built.overrideAttrs = prev: {
      preBuild = let
        haveTs = builtins.any ( p: p.pname == "typescript" ) prev.buildInputs;
      in prev.preBuild + ''
        echo 'haveTs: ${lib.boolToString haveTs}' >&2;
      '';
    };

  };


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
