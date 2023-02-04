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

  fmod0 = lib.evalModules {
    modules = [
      ../../../../modules/top
      {
        config.floco.buildPlan.deriveTreeInfo = true;
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
            fetchInfo = {
              type    = "tarball";
              url     = "https://registry.npmjs.org/which/-/which-2.0.2.tgz";
              narHash = "sha256-u114pFUXCCiUamLVVZma0Au+didZhD6RCoGTbrh2OhU=";
            };
            depInfo.isexe = {
              descriptor = "^2.0.0";
              runtime    = true;
              pin        = "2.0.0";
            };
          };
        };
      }
    ];
  };

  treeInfo0 = fmod0.config.floco.pdefs.which."2.0.2".treeInfo;

  ok0 = treeInfo0."node_modules/isexe" == {
    key      = "isexe/2.0.0";
    link     = true;
    dev      = false;
    optional = false;
  };


# ---------------------------------------------------------------------------- #

  fmod1 = lib.evalModules {
    modules = [
      ../../../../modules/top
      {
        config.floco.buildPlan.deriveTreeInfo = true;
        config.floco.pdefs = {
          semver."7.3.8" = {
            ident   = "semver";
            version = "7.3.8";
            ltype   = "file";
            binInfo.binPairs.semver = "bin/semver.js";
            fetchInfo = {
              type    = "tarball";
              url     = "https://registry.npmjs.org/semver/-/semver-7.3.8.tgz";
              narHash = "sha256-vqtjrIFs0Yw18hcdfShdL7BwyzqXdZ+K60Rp3oLNo/A=";
            };
            depInfo.lru-cache = {
              descriptor = "^6.0.0";
              runtime    = true;
              pin        = "6.0.0";
            };
          };
          lru-cache."6.0.0" = {
            ident     = "lru-cache";
            version   = "6.0.0";
            ltype     = "file";
            fetchInfo = {
              type = "tarball";
              url  =
                "https://registry.npmjs.org/lru-cache/-/lru-cache-6.0.0.tgz";
              narHash = "sha256-lBc6340YZYAh1Numj5iz418ChtGb3UUtRZLOYj/WJXg=";
            };
            depInfo.yallist = {
              descriptor = "^4.0.0";
              runtime    = true;
              pin        = "4.0.0";
            };
          };
          yallist."4.0.0" = {
            ident     = "yallist";
            version   = "4.0.0";
            ltype     = "file";
            fetchInfo = {
              narHash = "sha256-JQNNkqswg1ZH4o8PQS2R8WsZWJtv/5R3vRgc4d1vDR0=";
              type = "tarball";
              url = "https://registry.npmjs.org/yallist/-/yallist-4.0.0.tgz";
            };
            treeInfo = {};
          };
        };
      }
    ];
  };

  treeInfo1 = fmod1.config.floco.pdefs.semver."7.3.8".treeInfo;

  ok1 = let
    semver = treeInfo1 == {
      "node_modules/lru-cache" = {
        key      = "lru-cache/6.0.0";
        link     = true;
        dev      = false;
        optional = false;
      };
    };
    lru-cache = fmod1.config.floco.pdefs.lru-cache."6.0.0".treeInfo == {
      "node_modules/yallist" = {
        key      = "yallist/4.0.0";
        link     = true;
        dev      = false;
        optional = false;
      };
    };
  in semver && lru-cache;


# ---------------------------------------------------------------------------- #

in {
  inherit fmod0 fmod1 treeInfo0 treeInfo1 ok0 ok1;
  ok = ok0 && ok1;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
