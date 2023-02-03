{ lib, config, pkgs, pdef, floco, ... }: {

  _file = "<floco>/package/targets/implementation.nix";

  imports = [
    ./source/implementation.nix
    ./built/implementation.nix
    ./installed/implementation.nix
  ];

}
