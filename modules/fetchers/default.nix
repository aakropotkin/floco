{
  _file   = "<floco>/fetchers";
  imports = [
    ../fetcher/interface.nix
    ./interface.nix ./implementation.nix
  ];
}
