{
  imports = [../../../../modules/top];
  config.flocoPackages.pdefs."@floco/test"."4.2.0" = {
    ident      = "@floco/test";
    version    = "4.2.0";
    ltype      = "dir";
    sourceInfo.outPath = builtins.path {
      name   = "source";
      path   = ./.;
      filter = name: type: ( baseNameOf name ) == "package.json";
    };
  };
}
