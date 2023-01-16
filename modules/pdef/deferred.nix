# ============================================================================ #
#
# Prototype used for `options.floco.pdefs.*.*' submodules representing the
# declaration of a single Node.js pacakage/module.
#
# ---------------------------------------------------------------------------- #

{ lib, options, config, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.pdef = lib.mkOption {
    description = lib.mdDoc ''
      Abstract record used to declare a package/module at a specific version.
      This is a "deferred" module making it extensible.
      Its base interface must be implemented, but the implementations themselves
      may be swapped or overridden.
    '';
    type    = nt.deferredModuleWith { staticModules = [./interface.nix]; };
    default = {};
  };


# ---------------------------------------------------------------------------- #

  config.pdef = lib.mkDefault ( { ... }: {
    imports = [./implementation.nix];
    config._module.args = { inherit (config) fetchers; };
  } );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
