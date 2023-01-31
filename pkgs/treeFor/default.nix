# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
}: let

  fmod = ( lib.evalModules {
    modules = [
      ../../modules/top
      { config._module.args.pkgs = pkgsFor; }
      ./floco-cfg.nix
    ];
  } ).config.floco;

  pjs   = lib.importJSON ./package.json;
  ident = pjs.name;
  inherit (pjs) version;

in fmod.packages.${ident}.${version}.global // {
  meta = fmod.packages.${ident}.${version}.global.meta // {
    mainProgram = "treeFor";
    homepage    = "https://github.com/aakropotkin/floco";
    maintainers = ["Alex Ameen\u00e8s <alex.ameen.tx@gmail.com>"];
    license     = lib.licenses.gpl3Only;
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
