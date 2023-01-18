{ lib, config, pkgs, ... }: {
  _file   = "<floco>/top";
  imports = [./interface.nix ./implementation.nix];
}
