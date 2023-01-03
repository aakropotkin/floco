# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  lib = import ../../../lib {};

  ft = import ../../../modules/fetchInfo/types.nix { inherit lib; };

  lodashCfg = {
    type    = "tarball";
    url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
    narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
  };

in {

  lodash = ( lib.evalModules {
    modules = [
      { inherit (builtins.head ft.fetchTree.tarball.getSubModules) options; }
      lodashCfg
    ]; }
  ).config;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
