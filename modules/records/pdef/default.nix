{ lib, pkgs, ... }: {

  _file = "<floco>/records/pdef";

  imports = [
    ./binInfo
    ../depInfo ./depInfo/implementation.nix
    ./treeInfo
    ./peerInfo
    ./sysInfo
    ./fsInfo
    ./lifecycle
    ./interface.nix ./implementation.nix
  ];

  config._module.args.pdefs = lib.mkOverride 1400 {};

  # Very low priority fallback
  config._module.args.fetchers = lib.mkOverride 1400 (
    ( lib.evalModules {
      modules = [
        ../../fetchers
        { config._module.args = { inherit pkgs; }; }
      ];
      specialArgs = { inherit lib; };
    } ).config.fetchers
  );

  config._module.args.deriveTreeInfo = lib.mkOverride 1400 false;

}
