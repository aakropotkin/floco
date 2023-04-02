{
  floco = {
    pdefs = {
      "@floco/phony" = {
        "4.2.0" = {
          depInfo = {
            lodash = {
              descriptor = "^4.17.21";
              runtime = true;
            };
          };
          fetchInfo = "path:.";
          ident = "@floco/phony";
          lifecycle = {
            build = true;
          };
          ltype = "dir";
          treeInfo = {
            "node_modules/lodash" = {
              key = "lodash/4.17.21";
            };
          };
          version = "4.2.0";
        };
      };
      lodash = {
        "4.17.21" = {
          fetchInfo = {
            narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
            type = "tarball";
            url = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
          };
          ident = "lodash";
          ltype = "file";
          treeInfo = { };
          version = "4.17.21";
        };
      };
    };
  };
}