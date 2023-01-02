# ============================================================================ #
#
# Produces a `pdef' record from the default pipeline, pulling metadata from the
# NPM registry.
#
# ---------------------------------------------------------------------------- #

let
  inherit ( builtins.getFlake "nixpkgs" ) lib;
in ( lib.evalModules {
  modules = [../../../modules/pdef { ident = "lodash"; version = "4.17.21"; }];
} ).config._export


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #