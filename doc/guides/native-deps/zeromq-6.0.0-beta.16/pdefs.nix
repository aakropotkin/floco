{
  floco = {
    pdefs = {
      "@aminya/node-gyp-build" = {
        "4.5.0-aminya.4" = {
          binInfo = {
            binPairs = {
              node-gyp-build = "bin.js";
              node-gyp-build-optional = "optional.js";
              node-gyp-build-test = "build-test.js";
            };
          };
          fetchInfo = {
            narHash = "sha256-F24DZpoqVvxZy4KsZDIqY5vYyHTyTXLJbnD/6WmHKh0=";
            type = "tarball";
            url = "https://registry.npmjs.org/@aminya/node-gyp-build/-/node-gyp-build-4.5.0-aminya.4.tgz";
          };
          ident = "@aminya/node-gyp-build";
          ltype = "file";
          treeInfo = { };
          version = "4.5.0-aminya.4";
        };
      };
      balanced-match = {
        "1.0.2" = {
          fetchInfo = {
            narHash = "sha256-YH1+osaAiJvWUUR4VCe/Hh4eHhXS0gN3Lnr+Xd3cCzg=";
            type = "tarball";
            url = "https://registry.npmjs.org/balanced-match/-/balanced-match-1.0.2.tgz";
          };
          ident = "balanced-match";
          ltype = "file";
          treeInfo = { };
          version = "1.0.2";
        };
      };
      brace-expansion = {
        "1.1.11" = {
          depInfo = {
            balanced-match = {
              descriptor = "^1.0.0";
              pin = "1.0.2";
              runtime = true;
            };
            concat-map = {
              descriptor = "0.0.1";
              pin = "0.0.1";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-3iQ502QjW10IEFOh3qnkAIivIbQ1TO1pgQTi7p9eado=";
            type = "tarball";
            url = "https://registry.npmjs.org/brace-expansion/-/brace-expansion-1.1.11.tgz";
          };
          ident = "brace-expansion";
          ltype = "file";
          version = "1.1.11";
        };
      };
      concat-map = {
        "0.0.1" = {
          fetchInfo = {
            narHash = "sha256-ZY5/rMtzNK56p81EGaPcoIRr+J9j7yWh4szGxIOFYFA=";
            type = "tarball";
            url = "https://registry.npmjs.org/concat-map/-/concat-map-0.0.1.tgz";
          };
          ident = "concat-map";
          ltype = "file";
          treeInfo = { };
          version = "0.0.1";
        };
      };
      cross-env = {
        "7.0.3" = {
          binInfo = {
            binPairs = {
              cross-env = "src/bin/cross-env.js";
              cross-env-shell = "src/bin/cross-env-shell.js";
            };
          };
          depInfo = {
            cross-spawn = {
              descriptor = "^7.0.1";
              pin = "7.0.3";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-3jfPvb/kWivzpFD9A91I5UIhLlOw6Sct7z5ebOiBE9o=";
            type = "tarball";
            url = "https://registry.npmjs.org/cross-env/-/cross-env-7.0.3.tgz";
          };
          ident = "cross-env";
          ltype = "file";
          version = "7.0.3";
        };
      };
      cross-spawn = {
        "7.0.3" = {
          depInfo = {
            path-key = {
              descriptor = "^3.1.0";
              pin = "3.1.1";
              runtime = true;
            };
            shebang-command = {
              descriptor = "^2.0.0";
              pin = "2.0.0";
              runtime = true;
            };
            which = {
              descriptor = "^2.0.1";
              pin = "2.0.2";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-JZEEsKxB3BAGF+e9rlh4d9UUa8JEz4dSjfAvIXrerzY=";
            type = "tarball";
            url = "https://registry.npmjs.org/cross-spawn/-/cross-spawn-7.0.3.tgz";
          };
          ident = "cross-spawn";
          ltype = "file";
          version = "7.0.3";
        };
      };
      "fs.realpath" = {
        "1.0.0" = {
          fetchInfo = {
            narHash = "sha256-oPk2F5VP+ECdKr8qs3h0dziW0mK71uwTUrbgulLI/ks=";
            type = "tarball";
            url = "https://registry.npmjs.org/fs.realpath/-/fs.realpath-1.0.0.tgz";
          };
          ident = "fs.realpath";
          ltype = "file";
          treeInfo = { };
          version = "1.0.0";
        };
      };
      function-bind = {
        "1.1.1" = {
          fetchInfo = {
            narHash = "sha256-9SZTeDBJ87ogdiEHyC3b2/wr1Bv8qb8rCJeD+OYvf9A=";
            type = "tarball";
            url = "https://registry.npmjs.org/function-bind/-/function-bind-1.1.1.tgz";
          };
          ident = "function-bind";
          ltype = "file";
          treeInfo = { };
          version = "1.1.1";
        };
      };
      glob = {
        "7.2.3" = {
          depInfo = {
            "fs.realpath" = {
              descriptor = "^1.0.0";
              pin = "1.0.0";
              runtime = true;
            };
            inflight = {
              descriptor = "^1.0.4";
              pin = "1.0.6";
              runtime = true;
            };
            inherits = {
              descriptor = "2";
              pin = "2.0.4";
              runtime = true;
            };
            minimatch = {
              descriptor = "^3.1.1";
              pin = "3.1.2";
              runtime = true;
            };
            once = {
              descriptor = "^1.3.0";
              pin = "1.4.0";
              runtime = true;
            };
            path-is-absolute = {
              descriptor = "^1.0.0";
              pin = "1.0.1";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-QWp5le1Zd7QYp0SXrWVhX3TLZylTpU48NZ+D04pf6b4=";
            type = "tarball";
            url = "https://registry.npmjs.org/glob/-/glob-7.2.3.tgz";
          };
          ident = "glob";
          ltype = "file";
          version = "7.2.3";
        };
      };
      has = {
        "1.0.3" = {
          depInfo = {
            function-bind = {
              descriptor = "^1.1.1";
              pin = "1.1.1";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-z8QWvFmgxmKtQJ34TpRAZljXFJmXY0WUMPj1K64SHx4=";
            type = "tarball";
            url = "https://registry.npmjs.org/has/-/has-1.0.3.tgz";
          };
          ident = "has";
          ltype = "file";
          version = "1.0.3";
        };
      };
      inflight = {
        "1.0.6" = {
          depInfo = {
            once = {
              descriptor = "^1.3.0";
              pin = "1.4.0";
              runtime = true;
            };
            wrappy = {
              descriptor = "1";
              pin = "1.0.2";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-QYcVNxVNod45ft7XJVhWJCKuVPN95a8FwfAefYWKqhg=";
            type = "tarball";
            url = "https://registry.npmjs.org/inflight/-/inflight-1.0.6.tgz";
          };
          ident = "inflight";
          ltype = "file";
          version = "1.0.6";
        };
      };
      inherits = {
        "2.0.4" = {
          fetchInfo = {
            narHash = "sha256-EnwyCC7V9GbsUCFpqRNJtPNfbbEqyJTYxbRqR5SgYW0=";
            type = "tarball";
            url = "https://registry.npmjs.org/inherits/-/inherits-2.0.4.tgz";
          };
          ident = "inherits";
          ltype = "file";
          treeInfo = { };
          version = "2.0.4";
        };
      };
      interpret = {
        "1.4.0" = {
          fetchInfo = {
            narHash = "sha256-4SAOgXDv0YOOrSS/qrKVK4VMEOfOcmoje+CQmis1xG4=";
            type = "tarball";
            url = "https://registry.npmjs.org/interpret/-/interpret-1.4.0.tgz";
          };
          ident = "interpret";
          ltype = "file";
          treeInfo = { };
          version = "1.4.0";
        };
      };
      is-core-module = {
        "2.11.0" = {
          depInfo = {
            has = {
              descriptor = "^1.0.3";
              pin = "1.0.3";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-/nUASoPE2TWgzP0+HyPY6qEb67Kw1stZTtWMMykFcdY=";
            type = "tarball";
            url = "https://registry.npmjs.org/is-core-module/-/is-core-module-2.11.0.tgz";
          };
          ident = "is-core-module";
          ltype = "file";
          version = "2.11.0";
        };
      };
      isexe = {
        "2.0.0" = {
          fetchInfo = {
            narHash = "sha256-l3Fv+HpHS6H1TqfC1WSGjsGlX08oDHyHdsEu9JQkvhE=";
            type = "tarball";
            url = "https://registry.npmjs.org/isexe/-/isexe-2.0.0.tgz";
          };
          ident = "isexe";
          ltype = "file";
          treeInfo = { };
          version = "2.0.0";
        };
      };
      minimatch = {
        "3.1.2" = {
          depInfo = {
            brace-expansion = {
              descriptor = "^1.1.7";
              pin = "1.1.11";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-lngTO0Bk/Spf3t/zG5/j7C2STufjXWF5DlmKjvj1M8s=";
            type = "tarball";
            url = "https://registry.npmjs.org/minimatch/-/minimatch-3.1.2.tgz";
          };
          ident = "minimatch";
          ltype = "file";
          version = "3.1.2";
        };
      };
      minimist = {
        "1.2.8" = {
          fetchInfo = {
            narHash = "sha256-odj63qvs7TXmqy6XlhjY4qtPK5MUF5SZP4bznCdKSKY=";
            type = "tarball";
            url = "https://registry.npmjs.org/minimist/-/minimist-1.2.8.tgz";
          };
          ident = "minimist";
          ltype = "file";
          treeInfo = { };
          version = "1.2.8";
        };
      };
      node-addon-api = {
        "5.1.0" = {
          fetchInfo = {
            narHash = "sha256-tVT8YwNAZYM77s3DjxagbZZi84mTZMY66w6/rWDsk1g=";
            type = "tarball";
            url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-5.1.0.tgz";
          };
          ident = "node-addon-api";
          ltype = "file";
          treeInfo = { };
          version = "5.1.0";
        };
      };
      once = {
        "1.4.0" = {
          depInfo = {
            wrappy = {
              descriptor = "1";
              pin = "1.0.2";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-2NvvDZICNRZJPY258mO8rrRBg4fY7mlMjFEl2R+m348=";
            type = "tarball";
            url = "https://registry.npmjs.org/once/-/once-1.4.0.tgz";
          };
          ident = "once";
          ltype = "file";
          version = "1.4.0";
        };
      };
      path-is-absolute = {
        "1.0.1" = {
          fetchInfo = {
            narHash = "sha256-+DjPlEsONpIJ3kBveAhTRCV2aRZt3KN8RNLsgoC+jXk=";
            type = "tarball";
            url = "https://registry.npmjs.org/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
          };
          ident = "path-is-absolute";
          ltype = "file";
          treeInfo = { };
          version = "1.0.1";
        };
      };
      path-key = {
        "3.1.1" = {
          fetchInfo = {
            narHash = "sha256-gj4CYT2AeZ5jyhV6m/eAq4pETAxmqd5kAcw/Iw0yxiI=";
            type = "tarball";
            url = "https://registry.npmjs.org/path-key/-/path-key-3.1.1.tgz";
          };
          ident = "path-key";
          ltype = "file";
          treeInfo = { };
          version = "3.1.1";
        };
      };
      path-parse = {
        "1.0.7" = {
          fetchInfo = {
            narHash = "sha256-IO0Y8yjZA6xJ63eLG/nFzWTGjI5tREyNKttz4DXoKYo=";
            type = "tarball";
            url = "https://registry.npmjs.org/path-parse/-/path-parse-1.0.7.tgz";
          };
          ident = "path-parse";
          ltype = "file";
          treeInfo = { };
          version = "1.0.7";
        };
      };
      rechoir = {
        "0.6.2" = {
          depInfo = {
            resolve = {
              descriptor = "^1.1.6";
              pin = "1.22.1";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-Sp0alJk/IkJnudnWyOcMYTubwrHmZ7NyFNmUWrbbCic=";
            type = "tarball";
            url = "https://registry.npmjs.org/rechoir/-/rechoir-0.6.2.tgz";
          };
          ident = "rechoir";
          ltype = "file";
          version = "0.6.2";
        };
      };
      resolve = {
        "1.22.1" = {
          binInfo = {
            binPairs = {
              resolve = "bin/resolve";
            };
          };
          depInfo = {
            is-core-module = {
              descriptor = "^2.9.0";
              pin = "2.11.0";
              runtime = true;
            };
            path-parse = {
              descriptor = "^1.0.7";
              pin = "1.0.7";
              runtime = true;
            };
            supports-preserve-symlinks-flag = {
              descriptor = "^1.0.0";
              pin = "1.0.0";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-7Z/261GRkso9A8/SZR0DTykpeA02Y270stCuAj7lmGE=";
            type = "tarball";
            url = "https://registry.npmjs.org/resolve/-/resolve-1.22.1.tgz";
          };
          ident = "resolve";
          ltype = "file";
          version = "1.22.1";
        };
      };
      shebang-command = {
        "2.0.0" = {
          depInfo = {
            shebang-regex = {
              descriptor = "^3.0.0";
              pin = "3.0.0";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-hQ8ZmBxEUTBeAoFsrXtJSMXkxZPNJhOEvKatEpvbpaE=";
            type = "tarball";
            url = "https://registry.npmjs.org/shebang-command/-/shebang-command-2.0.0.tgz";
          };
          ident = "shebang-command";
          ltype = "file";
          version = "2.0.0";
        };
      };
      shebang-regex = {
        "3.0.0" = {
          fetchInfo = {
            narHash = "sha256-20gU7k4uzL2AgOQ9iw2L1KH8sC6GaQCZtjyUBY5ayQ0=";
            type = "tarball";
            url = "https://registry.npmjs.org/shebang-regex/-/shebang-regex-3.0.0.tgz";
          };
          ident = "shebang-regex";
          ltype = "file";
          treeInfo = { };
          version = "3.0.0";
        };
      };
      shelljs = {
        "0.8.5" = {
          binInfo = {
            binPairs = {
              shjs = "bin/shjs";
            };
          };
          depInfo = {
            glob = {
              descriptor = "^7.0.0";
              pin = "7.2.3";
              runtime = true;
            };
            interpret = {
              descriptor = "^1.0.0";
              pin = "1.4.0";
              runtime = true;
            };
            rechoir = {
              descriptor = "^0.6.2";
              pin = "0.6.2";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-26S3UcP0UpxagaHpDOl6mrVqT5hZTeRwHZijkG6zpHs=";
            type = "tarball";
            url = "https://registry.npmjs.org/shelljs/-/shelljs-0.8.5.tgz";
          };
          ident = "shelljs";
          ltype = "file";
          version = "0.8.5";
        };
      };
      shx = {
        "0.3.4" = {
          binInfo = {
            binPairs = {
              shx = "lib/cli.js";
            };
          };
          depInfo = {
            minimist = {
              descriptor = "^1.2.3";
              pin = "1.2.8";
              runtime = true;
            };
            shelljs = {
              descriptor = "^0.8.5";
              pin = "0.8.5";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-mRNiu+XwmCHYeivJHNZcaw8B5eNbAHTdfhKrZKN0gZ0=";
            type = "tarball";
            url = "https://registry.npmjs.org/shx/-/shx-0.3.4.tgz";
          };
          ident = "shx";
          ltype = "file";
          version = "0.3.4";
        };
      };
      supports-preserve-symlinks-flag = {
        "1.0.0" = {
          fetchInfo = {
            narHash = "sha256-Gwf/IHn+m17+KsKxcOrhCxAjvH8uxQx8Bud+qeCNwKg=";
            type = "tarball";
            url = "https://registry.npmjs.org/supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz";
          };
          ident = "supports-preserve-symlinks-flag";
          ltype = "file";
          treeInfo = { };
          version = "1.0.0";
        };
      };
      which = {
        "2.0.2" = {
          binInfo = {
            binPairs = {
              node-which = "bin/node-which";
            };
          };
          depInfo = {
            isexe = {
              descriptor = "^2.0.0";
              pin = "2.0.0";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-u114pFUXCCiUamLVVZma0Au+didZhD6RCoGTbrh2OhU=";
            type = "tarball";
            url = "https://registry.npmjs.org/which/-/which-2.0.2.tgz";
          };
          ident = "which";
          ltype = "file";
          version = "2.0.2";
        };
      };
      wrappy = {
        "1.0.2" = {
          fetchInfo = {
            narHash = "sha256-8EvxGsoK2efCTAOoAHPbfbCoPOJvkmOLPM4XA1rEcVU=";
            type = "tarball";
            url = "https://registry.npmjs.org/wrappy/-/wrappy-1.0.2.tgz";
          };
          ident = "wrappy";
          ltype = "file";
          treeInfo = { };
          version = "1.0.2";
        };
      };
      zeromq = {
        "6.0.0-beta.16" = {
          depInfo = {
            "@aminya/node-gyp-build" = {
              descriptor = "4.5.0-aminya.4";
              pin = "4.5.0-aminya.4";
              runtime = true;
            };
            cross-env = {
              descriptor = "^7.0.3";
              pin = "7.0.3";
              runtime = true;
            };
            node-addon-api = {
              descriptor = "^5.0.0";
              pin = "5.1.0";
              runtime = true;
            };
            shelljs = {
              descriptor = "^0.8.5";
              pin = "0.8.5";
              runtime = true;
            };
            shx = {
              descriptor = "^0.3.4";
              pin = "0.3.4";
              runtime = true;
            };
          };
          fetchInfo = {
            narHash = "sha256-Rkz70DS5B23h0YegYPomcc3bmRB4C98PDXTXzSl8pOY=";
            type = "tarball";
            url = "https://registry.npmjs.org/zeromq/-/zeromq-6.0.0-beta.16.tgz";
          };
          ident = "zeromq";
          lifecycle = {
            install = true;
          };
          ltype = "file";
          treeInfo = {
            "node_modules/@aminya/node-gyp-build" = {
              key = "@aminya/node-gyp-build/4.5.0-aminya.4";
            };
            "node_modules/balanced-match" = {
              key = "balanced-match/1.0.2";
            };
            "node_modules/brace-expansion" = {
              key = "brace-expansion/1.1.11";
            };
            "node_modules/concat-map" = {
              key = "concat-map/0.0.1";
            };
            "node_modules/cross-env" = {
              key = "cross-env/7.0.3";
            };
            "node_modules/cross-spawn" = {
              key = "cross-spawn/7.0.3";
            };
            "node_modules/fs.realpath" = {
              key = "fs.realpath/1.0.0";
            };
            "node_modules/function-bind" = {
              key = "function-bind/1.1.1";
            };
            "node_modules/glob" = {
              key = "glob/7.2.3";
            };
            "node_modules/has" = {
              key = "has/1.0.3";
            };
            "node_modules/inflight" = {
              key = "inflight/1.0.6";
            };
            "node_modules/inherits" = {
              key = "inherits/2.0.4";
            };
            "node_modules/interpret" = {
              key = "interpret/1.4.0";
            };
            "node_modules/is-core-module" = {
              key = "is-core-module/2.11.0";
            };
            "node_modules/isexe" = {
              key = "isexe/2.0.0";
            };
            "node_modules/minimatch" = {
              key = "minimatch/3.1.2";
            };
            "node_modules/minimist" = {
              key = "minimist/1.2.8";
            };
            "node_modules/node-addon-api" = {
              key = "node-addon-api/5.1.0";
            };
            "node_modules/once" = {
              key = "once/1.4.0";
            };
            "node_modules/path-is-absolute" = {
              key = "path-is-absolute/1.0.1";
            };
            "node_modules/path-key" = {
              key = "path-key/3.1.1";
            };
            "node_modules/path-parse" = {
              key = "path-parse/1.0.7";
            };
            "node_modules/rechoir" = {
              key = "rechoir/0.6.2";
            };
            "node_modules/resolve" = {
              key = "resolve/1.22.1";
            };
            "node_modules/shebang-command" = {
              key = "shebang-command/2.0.0";
            };
            "node_modules/shebang-regex" = {
              key = "shebang-regex/3.0.0";
            };
            "node_modules/shelljs" = {
              key = "shelljs/0.8.5";
            };
            "node_modules/shx" = {
              key = "shx/0.3.4";
            };
            "node_modules/supports-preserve-symlinks-flag" = {
              key = "supports-preserve-symlinks-flag/1.0.0";
            };
            "node_modules/which" = {
              key = "which/2.0.2";
            };
            "node_modules/wrappy" = {
              key = "wrappy/1.0.2";
            };
          };
          version = "6.0.0-beta.16";
        };
      };
    };
  };
}