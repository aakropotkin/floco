{
  floco = {
    pdefs = {
      nan = {
        "2.17.0" = {
          fetchInfo = {
            narHash = "sha256-5r+kH/G43Jk8vchs/zzepgd/5ouh0hIG7lWc6OfxLJ0=";
            type = "tarball";
            url = "https://registry.npmjs.org/nan/-/nan-2.17.0.tgz";
          };
          ident = "nan";
          ltype = "file";
          treeInfo = { };
          version = "2.17.0";
        };
      };
      node-gyp-build = {
        "4.6.0" = {
          binInfo = {
            binPairs = {
              node-gyp-build = "bin.js";
              node-gyp-build-optional = "optional.js";
              node-gyp-build-test = "build-test.js";
            };
          };
          fetchInfo = {
            narHash = "sha256-Xcesss9lGAr2gkew7FvFQB+0quNpbmN3ZPl2Rh31pME=";
            type = "tarball";
            url = "https://registry.npmjs.org/node-gyp-build/-/node-gyp-build-4.6.0.tgz";
          };
          ident = "node-gyp-build";
          ltype = "file";
          treeInfo = { };
          version = "4.6.0";
        };
      };
      zeromq = {
        "5.3.1" = {
          depInfo = {
            nan = {
              descriptor = "2.17.0";
              pin = "2.17.0";
              runtime = true;
            };
            node-gyp-build = {
              descriptor = "^4.5.0";
              pin = "4.6.0";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-Z3WYfW0oQFgtj5DHrMCCnP5+3e2XZarwFk4xOjxTyDA=";
            type = "tarball";
            url = "https://registry.npmjs.org/zeromq/-/zeromq-5.3.1.tgz";
          };
          ident = "zeromq";
          lifecycle = {
            install = true;
          };
          ltype = "file";
          treeInfo = {
            "node_modules/nan" = {
              key = "nan/2.17.0";
            };
            "node_modules/node-gyp-build" = {
              key = "node-gyp-build/4.6.0";
            };
          };
          version = "5.3.1";
        };
      };
    };
  };
}