# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../../../../../lib {} }: let

# ---------------------------------------------------------------------------- #

  mod = lib.evalModules {
    modules = [
      ../../../../../modules/top
      ./floco-cfg.nix
    ];
  };

  inherit (mod.config.floco) pdefs;


# ---------------------------------------------------------------------------- #

in lib.runTests {

  testDeserialHasDev = {
    expr     = pdefs."@floco/phony"."4.2.0".depInfo.lodash.dev;
    expected = true;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #