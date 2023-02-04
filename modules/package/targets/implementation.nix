{ lib, config, pkgs, pdef, target, packages, ... }: {

  _file = "<floco>/package/targets/implementation.nix";

  imports = [
    ./source/implementation.nix
    ./built/implementation.nix
    ./installed/implementation.nix
  ];

}
