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

  config._module.args.fetchers = lib.mkDefault (
    ( lib.evalModules { modules = [../fetchers]; } ).config.fetchers
  );

}
