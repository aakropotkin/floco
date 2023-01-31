# ============================================================================ #
#
# Ensures that pinned `depInfo' information allows linked forms of `treeInfo'
# to be inferred.
#
# ---------------------------------------------------------------------------- #

{ lib     ? import ../../../../lib {}
, nixpkgs ? ( import ../../../../inputs ).nixpkgs.flake
, system  ? builtins.currentSystem
, pkgsFor ?
  nixpkgs.legacyPackages.${system}.extend ( import ../../../../overlay.nix )
}: let

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      ../../../../modules/top
      {
        config.floco.pdefs = {
          isexe."2.0.0" = {
            ident   = "isexe";
            version = "2.0.0";
            ltype   = "file";
            fetchInfo = {
              type    = "tarball";
              url     = "https://registry.npmjs.org/isexe/-/isexe-2.0.0.tgz";
              narHash = "sha256-l3Fv+HpHS6H1TqfC1WSGjsGlX08oDHyHdsEu9JQkvhE=";
            };
            treeInfo = {};
          };
          which."2.0.2" = {
            ident   = "which";
            version = "2.0.2";
            ltype   = "file";
            binInfo.binPairs.node-which = "bin/node-which";
            depInfo.isexe = {
              descriptor = "^2.0.0";
              runtime    = true;
              pin        = "2.0.0";
            };
            fetchInfo = {
              type    = "tarball";
              url     = "https://registry.npmjs.org/which/-/which-2.0.2.tgz";
              narHash = "sha256-u114pFUXCCiUamLVVZma0Au+didZhD6RCoGTbrh2OhU=";
            };
          };
        };
      }
    ];
  };


# ---------------------------------------------------------------------------- #

  inherit (fmod.config.floco.pdefs.which."2.0.2") treeInfo;


# ---------------------------------------------------------------------------- #

in {
  inherit treeInfo;
  ok = treeInfo."node_modules/isexe" == {
    key      = "isexe/2.0.0";
    link     = true;
    dev      = false;
    optional = false;
  };
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
