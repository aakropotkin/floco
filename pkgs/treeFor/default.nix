# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs      ? ( import ../../inputs ).nixpkgs.flake
, lib          ? import ../../lib { inherit (nixpkgs) lib; }
, system       ? builtins.currentSystem
, pkgsFor      ? nixpkgs.legacyPackages.${system}
, extraModules ? []
}: let

# ---------------------------------------------------------------------------- #

  fmod = ( lib.evalModules {
    modules = [
      ../../modules/top
      ../../modules/configs/use-fetchzip.nix
      {
        config._module.args.pkgs = pkgsFor;
        config.floco.settings    = { inherit system; basedir = ./.; };
      }
      ./floco-cfg.nix
    ] ++ ( lib.toList extraModules );
  } ).config.floco;


# ---------------------------------------------------------------------------- #

  pjs   = lib.importJSON ./package.json;
  ident = pjs.name;
  inherit (pjs) version;


# ---------------------------------------------------------------------------- #

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
