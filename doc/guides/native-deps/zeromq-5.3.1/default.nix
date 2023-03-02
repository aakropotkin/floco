{ floco     ? builtins.getFlake "github:aakropotkin/floco"
, lib       ? floco.lib
, system    ? builtins.currentSystem
, ...
}: let
  mod = lib.evalModules {
    modules = [
      floco.nixosModules.default
      ./floco-cfg.nix
      { floco.settings = { inherit system; }; }
    ];
  };
in mod.config.floco.packages.zeromq."5.3.1".global

