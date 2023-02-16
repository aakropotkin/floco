# ============================================================================ #
#
# Prototype used for `options.floco.pdefs.*.*' submodules representing the
# declaration of a single Node.js pacakage/module.
#
# ---------------------------------------------------------------------------- #

{ lib
, options
, config
, pkgs
, system
, floco
, ...
} @ top: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef";

# ---------------------------------------------------------------------------- #

  options.pdef = lib.mkOption {
    description = lib.mdDoc ''
      Abstract record used to declare a package/module at a specific version.

      This is a "deferred" module making it extensible.
      Its base interface must be implemented, but the implementations themselves
      may be swapped or overridden.
    '';
    type = nt.deferredModuleWith {
      staticModules = [
        top.config.depInfo.deferred
        ./interface.nix
      ];
    };
  };


# ---------------------------------------------------------------------------- #

  config._module.args.system = lib.mkDefault builtins.currentSystem;
  config._module.args.pkgs   = let
    nixpkgs = ( import ../../../inputs ).nixpkgs.flake;
    pkgsFor = nixpkgs.legacyPackages.${system};
    withOv  = pkgsFor.extend ( import ../../../overlay.nix );
  in lib.mkOverride 1400 withOv;
  config._module.args.floco = {
    pdefs    = {};
    fetchers = ( lib.evalModules {
      modules = [
        ../../fetchers
        { config._module.args = { inherit pkgs; }; }
      ];
      specialArgs = { inherit lib; };
    } ).config.fetchers;
    buildPlan.deriveTreeInfo = false;
  };


# ---------------------------------------------------------------------------- #

  config.pdef = { config, options, ... }: {
    imports = [
      ./implementation.nix
    ];
    config._export =
      lib.mkDerivedConfig options.depInfo top.config.depInfo.serialize;
    config._module.args.pkgs     = lib.mkOverride 999  pkgs;
    config._module.args.fetchers = lib.mkOverride 999  floco.fetchers;
    config._module.args.pdefs    = lib.mkOverride 1001 floco.pdefs;
    config._module.args.basedir  = lib.mkOverride 999  floco.settings.basedir;

    config._module.args.deriveTreeInfo =
      lib.mkOverride 999 ( floco.buildPlan.deriveTreeInfo or false );
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
