# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

# ---------------------------------------------------------------------------- #

  pjs = lib.importJSON ./package.json;
  cfg = config.floco.packages.${pjs.name}.${pjs.version};

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  imports = [
    ./pdefs.nix
    ../../fpkgs/arborist/floco-cfg.nix
  ];


# ---------------------------------------------------------------------------- #

  config.floco.buildPlan.deriveTreeInfo = true;


# ---------------------------------------------------------------------------- #

  config.floco.packages.${pjs.name}.${pjs.version} = let
    arbv = baseNameOf cfg.pdef.treeInfo."node_modules/@npmcli/arborist".key;
    arbp = config.floco.packages."@npmcli/arborist".${arbv};
    inherit (pkgs) system;
  in {
    trees.prod = derivation {
      inherit system;
      name     = "node_modules";
      builder  = "${pkgs.bash}/bin/bash";
      PATH     = "${pkgs.coreutils}/bin";
      arborist = arbp.global.outPath;
      args     = ["-euc" ''
        mkdir -p "$out";
        ln -s "$arborist/lib/node_modules" "$out/node_modules";
      ''];
      preferLocalBuild = true;
      allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
