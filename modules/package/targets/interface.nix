{

  _file = "<floco>/targets/interface.nix";

  imports = [
    ./source/interface.nix
    ./built/interface.nix
    ./installed/interface.nix
  ];

}
