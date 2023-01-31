{
  floco.pdefs = {

    isexe."2.0.0" = {
      ident   = "isexe";
      version = "2.0.0";
      ltype   = "file";
      fetchInfo = {
        narHash = "sha256-l3Fv+HpHS6H1TqfC1WSGjsGlX08oDHyHdsEu9JQkvhE=";
        type = "tarball";
        url = "https://registry.npmjs.org/isexe/-/isexe-2.0.0.tgz";
      };
      treeInfo = { };
    };

    which."2.0.2" = {
      ident   = "which";
      version = "2.0.2";
      ltype   = "file";
      binInfo.binPairs.node-which = "bin/node-which";
      depInfo.isexe = {
        descriptor = "^2.0.0";
        runtime    = true;
      };
      fetchInfo = {
        type    = "tarball";
        url     = "https://registry.npmjs.org/which/-/which-2.0.2.tgz";
        narHash = "sha256-u114pFUXCCiUamLVVZma0Au+didZhD6RCoGTbrh2OhU=";
      };
      treeInfo."node_modules/isexe".key = "isexe/2.0.0";
    };

  };
}
