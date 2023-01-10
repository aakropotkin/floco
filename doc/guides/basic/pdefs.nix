[
  {
    binInfo = {
      binPairs = {
        test = "bin.js";
      };
    };
    depInfo = {
      "@types/lodash" = {
        descriptor = "^4.14.191";
      };
      lodash = {
        descriptor = "^4.17.21";
        runtime = true;
      };
      typescript = {
        descriptor = "^4.9.4";
      };
    };
    fetchInfo = {
      path = ./.;
    };
    ident = "@floco/test";
    lifecycle = {
      build = true;
    };
    ltype = "dir";
    treeInfo = {
      "node_modules/@types/lodash" = {
        dev = true;
        key = "@types/lodash/4.14.191";
      };
      "node_modules/lodash" = {
        key = "lodash/4.17.21";
      };
      #"node_modules/typescript" = {
      #  dev = true;
      #  key = "typescript/4.9.4";
      #};
    };
    version = "4.2.0";
  }
  {
    fetchInfo = {
      narHash = "sha256-vAXLkxcv8EkBcMBk8Z3XfL3yvQXVHqxBslDlCbG4+pg=";
      type = "tarball";
      url = "https://registry.npmjs.org/@types/lodash/-/lodash-4.14.191.tgz";
    };
    ident = "@types/lodash";
    ltype = "file";
    treeInfo = { };
    version = "4.14.191";
  }
  {
    fetchInfo = {
      narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
      type = "tarball";
      url = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
    };
    ident = "lodash";
    ltype = "file";
    treeInfo = { };
    version = "4.17.21";
  }
  {
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
  }
]
