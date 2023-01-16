{
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
  # Inlines the result of `lib.mkDefault' to avoid making this file a function.
  config._module.args.fetchers = {
    _type    = "override";
    priority = 1000;
    content  = ( lib.evalModules { modules = [../fetchers]; } ).config.fetchers;
  };
}
