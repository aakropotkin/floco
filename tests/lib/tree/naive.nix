# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../../../lib {} }: let

  mod = lib.evalModules {
    modules = [
      ../../../modules/top
      ../data/pacote/floco-cfg.nix
    ];
  };

  info = import ../data/pacote/info.nix;

  
# ---------------------------------------------------------------------------- #

  treeInfo = lib.libfloco.mkTreeInfoWith mod info;


# ---------------------------------------------------------------------------- #

in lib.runTests {
  testMkTreeInfoNaive = {
    expr     = builtins.isAttrs ( builtins.deepSeq treeInfo treeInfo );
    expected = true;
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
