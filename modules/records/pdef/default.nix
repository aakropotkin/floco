{ lib, pkgs, ... }: let
  mod = lib.evalModules {
    modules = [./deferred.nix { config._module.args = { inherit pkgs; }; }];
  };
in mod.config.pdef
