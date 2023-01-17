{ lib, ... }: {

  _file = "<floco>/pdef";

  imports = [
    ./binInfo
    ./depInfo
    ./treeInfo
    ./peerInfo
    ./sysInfo
    ./fsInfo
    ./lifecycle
    ./interface.nix ./implementation.nix
  ];

  # Very low priority fallback
  config._module.args.fetchers = lib.mkOverride 1400 (
    ( lib.evalModules { modules = [../fetchers]; } ).config.fetchers
  );

}
