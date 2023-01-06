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

  floco = ( lib.evalModules {
    modules = [
      { config._module.args.pkgs = pkgsFor; }
      ../../modules/top
      ( lib.addPdefs ./pdefs.nix )
      {
        config.flocoPackages.packages."@floco/treefor"."0.1.0".source =
          lib.mkForce ( builtins.path {
            name   = "source";
            path   = ./.;
            filter = name: type:
              ( ( baseNameOf name ) != "node_modules" ) &&
              ( ( builtins.match ".*\\.nix" name ) == null );
          } );
      }
    ];
  } ).config.flocoPackages;

in floco.packages."@floco/treefor"."0.1.0".global // {
  meta = floco.packages."@floco/treefor"."0.1.0".global.meta // {
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
