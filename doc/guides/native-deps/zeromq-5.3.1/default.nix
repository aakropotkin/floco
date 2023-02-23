{ floco     ? builtins.getFlake "github:aakropotkin/floco"
, lib       ? floco.lib
, system    ? builtins.currentSystem
, floco-cfg ? ./floco-cfg.nix
, ...
}: let
  mod = lib.evalModules {
    modules = [
      floco.nixosModules.default
      floco-cfg
      { floco.settings = { inherit system; }; }
    ];
  };
in mod.config.floco.packages.zeromq."5.3.1".global

