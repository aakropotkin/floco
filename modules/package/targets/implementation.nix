{ lib, config, pkgs, floco, ... }: {
  imports = [
    ./source/implementation.nix
    ./built/implementation.nix
    ./installed/implementation.nix
  ];
}
