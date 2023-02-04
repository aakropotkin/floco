{
  floco = {
    pdefs = {
      "@floco/test" = {
        "4.2.0" = {
          binInfo = {
            binPairs = {
              test = "bin.js";
            };
          };
          depInfo = {
            "@types/lodash" = {
              descriptor = "^4.14.191";
              pin = "4.14.191";
            };
            lodash = {
              descriptor = "^4.17.21";
              pin = "4.17.21";
              runtime = true;
            };
            typescript = {
              descriptor = "^4.9.4";
              pin = "4.9.4";
            };
          };
          fetchInfo = "path:.";
          ident = "@floco/test";
          lifecycle = {
            build = true;
          };
          ltype = "dir";
          version = "4.2.0";
        };
      };
      "@types/lodash" = {
        "4.14.191" = {
          fetchInfo = {
            narHash = "sha256-vAXLkxcv8EkBcMBk8Z3XfL3yvQXVHqxBslDlCbG4+pg=";
            type = "tarball";
            url = "https://registry.npmjs.org/@types/lodash/-/lodash-4.14.191.tgz";
          };
          ident = "@types/lodash";
          ltype = "file";
          treeInfo = { };
          version = "4.14.191";
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
      typescript = {
        "4.9.4" = {
          binInfo = {
            binPairs = {
              tsc = "bin/tsc";
              tsserver = "bin/tsserver";
            };
          };
          fetchInfo = {
            narHash = "sha256-fAY3tqKrWXeHWil6vfsIuodWt8KAwDXjq5Tj9M5yq7o=";
            type = "tarball";
            url = "https://registry.npmjs.org/typescript/-/typescript-4.9.4.tgz";
          };
          ident = "typescript";
          ltype = "file";
          treeInfo = { };
          version = "4.9.4";
        };
      };
    };
  };
}