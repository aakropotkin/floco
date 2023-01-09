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
      {
        config._module.args.pkgs = pkgsFor;
      }
      ( lib.addPdefs ./pdefs.nix )
      #{
      #  config.floco.packages."@floco/treefor"."0.1.0".source =
      #    lib.mkForce ( builtins.path {
      #      name   = "source";
      #      path   = ./.;
      #      filter = name: type:
      #        ( ! ( builtins.elem ( baseNameOf name ) [
      #                "node_modules" "result"
      #              ] ) ) &&
      #        ( ( builtins.match ".*\\.nix" name ) == null );
      #    } );
      #}
      ../../modules/top
    ];
  } ).config.floco;

in fmod.packages."@floco/treefor"."0.1.0".global // {
  meta = fmod.packages."@floco/treefor"."0.1.0".global.meta // {
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
