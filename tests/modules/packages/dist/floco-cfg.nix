{
  config.floco.pdefs."@floco/test"."4.2.0" = {
    ident      = "@floco/test";
    version    = "4.2.0";
    ltype      = "dir";
    fetchInfo  = {
      name   = "source";
      path   = ./.;
      filter = name: type: ( baseNameOf name ) == "package.json";
    };
  };
}
