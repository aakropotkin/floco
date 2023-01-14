# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.pdefs = lib.mkOption {

    description = lib.mdDoc ''
      List of `pdef` metadata records for all known pacakges
      and modules.
      These records are used to generate build recipes and build plans.
    '';

    type = nt.lazyAttrsOf ( nt.lazyAttrsOf ( nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules                    = [];
    } ) );

    example = {
      lodash."4.17.21" = {
        ident     = "lodash";
        version   = "4.17.21";
        ltype     = "file";
        fetchInfo = {
          type    = "tarball";
          url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
          narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
        };
        treeInfo = {};
      };
      acorn."8.8.1" = {
        key   = "acorn/8.8.1";
        ltype = "file";
        binInfo.binPairs.acorn = "./bin/acorn";
        fetchInfo = {
          type    = "tarball";
          narHash = "sha256-W14mU7fhfZajYWDfzRxzSMexNSYKIg63yXSnM/vG0P8=";
          url     = "https://registry.npmjs.org/acorn/-/acorn-8.8.1.tgz";
        };
        treeInfo = {};
      };
    };

    default = {};

  };  # End `options.pdefs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
