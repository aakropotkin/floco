# ============================================================================ #
#
# Prototype used for `options.floco.pdefs.*.*' submodules representing the
# declaration of a single Node.js pacakage/module.
#
# ---------------------------------------------------------------------------- #

{ lib, options, config, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdef/deferred.nix";

# ---------------------------------------------------------------------------- #

  options.pdef = lib.mkOption {
    description = lib.mdDoc ''
      Abstract record used to declare a package/module at a specific version.
      This is a "deferred" module making it extensible.
      Its base interface must be implemented, but the implementations themselves
      may be swapped or overridden.
    '';
    type = nt.deferredModuleWith {
      staticModules = [./interface.nix];
    };
    default = {};
  };


# ---------------------------------------------------------------------------- #

  config.pdef = { ... }: {
    imports = [./implementation.nix];
    config._module.args.fetchers = config.fetchers;
    config._module.args.pkgs     = pkgs;
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
