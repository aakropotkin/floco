{
  floco.pdefs."@floco/treefor"."0.1.0" = {
    depInfo = {
      "@npmcli/arborist" = {
        descriptor = "6.1.5";
        runtime = true;
      };
    };
    binInfo = {
      binPairs = {
        "treeFor" = "./bin.js";
      };
    };
    fetchInfo = {
      path = ./.;
    };
    ident = "@floco/treefor";
    ltype = "dir";
    treeInfo = {
      "node_modules/@npmcli/arborist" = {
        key  = "@npmcli/arborist/6.1.5";
        link = true;
      };
    };
    version = "0.1.0";
  };
}
