{
  config.floco.pdefs = {
    "@gar/promisify" = {
      "1.1.3" = {
        fetchInfo = {
          narHash = "sha256-q14DlqUn1aVF80MfLxXplN5KlRvV1R1JAXMmTViAPWo=";
          type = "tarball";
          url = "https://registry.npmjs.org/@gar/promisify/-/promisify-1.1.3.tgz";
        };
        ident = "@gar/promisify";
        ltype = "file";
        treeInfo = { };
        version = "1.1.3";
      };
    };
    "@npmcli/fs" = {
      "1.1.1" = {
        depInfo = {
          "@gar/promisify" = {
            descriptor = "^1.0.1";
            pin = "1.1.3";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-sGmxA2bp/A+LtEi3+i9CE5NtYiM3UqtkdPDxEtnlKXA=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/fs/-/fs-1.1.1.tgz";
        };
        ident = "@npmcli/fs";
        ltype = "file";
        version = "1.1.1";
      };
      "2.1.2" = {
        depInfo = {
          "@gar/promisify" = {
            descriptor = "^1.1.3";
            pin = "1.1.3";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-xbnGGVcO6ee/Wllx/8Esksud2IDo6dVxJ5hmdCit3A0=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/fs/-/fs-2.1.2.tgz";
        };
        ident = "@npmcli/fs";
        ltype = "file";
        version = "2.1.2";
      };
    };
    "@npmcli/git" = {
      "3.0.2" = {
        depInfo = {
          "@npmcli/promise-spawn" = {
            descriptor = "^3.0.0";
            pin = "3.0.0";
            runtime = true;
          };
          lru-cache = {
            descriptor = "^7.4.4";
            pin = "7.14.1";
            runtime = true;
          };
          mkdirp = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          npm-pick-manifest = {
            descriptor = "^7.0.0";
            pin = "7.0.2";
            runtime = true;
          };
          proc-log = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
          promise-inflight = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          promise-retry = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
          which = {
            descriptor = "^2.0.2";
            pin = "2.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-5dOoxgIFmntUJ/dtucXt2qJS8dvfDNDzPhU33y2RIPY=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/git/-/git-3.0.2.tgz";
        };
        ident = "@npmcli/git";
        ltype = "file";
        version = "3.0.2";
      };
    };
    "@npmcli/installed-package-contents" = {
      "1.0.7" = {
        binInfo = {
          binPairs = {
            installed-package-contents = "index.js";
          };
        };
        depInfo = {
          npm-bundled = {
            descriptor = "^1.1.1";
            pin = "1.1.2";
            runtime = true;
          };
          npm-normalize-package-bin = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-qMSHFhmwbZ9Gp9vcKnHfCJqxFgTPC87N9WzPQDg6eDc=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/installed-package-contents/-/installed-package-contents-1.0.7.tgz";
        };
        ident = "@npmcli/installed-package-contents";
        ltype = "file";
        version = "1.0.7";
      };
    };
    "@npmcli/move-file" = {
      "1.1.2" = {
        depInfo = {
          mkdirp = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-P9JjmfeMEHO6k6i04aRRA2A0WS0i7l2GFWOcDLxXZfE=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/move-file/-/move-file-1.1.2.tgz";
        };
        ident = "@npmcli/move-file";
        ltype = "file";
        version = "1.1.2";
      };
      "2.0.1" = {
        depInfo = {
          mkdirp = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-SiXkW7ZoPcAdXgojdC12evp8tEQIiommzWyuwuFglZU=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/move-file/-/move-file-2.0.1.tgz";
        };
        ident = "@npmcli/move-file";
        ltype = "file";
        version = "2.0.1";
      };
    };
    "@npmcli/node-gyp" = {
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-i5K99BDKF025sNtvFLqHzxcTgolEIhXUdVRii8ELjnQ=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/node-gyp/-/node-gyp-2.0.0.tgz";
        };
        ident = "@npmcli/node-gyp";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    "@npmcli/promise-spawn" = {
      "3.0.0" = {
        depInfo = {
          infer-owner = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-931TjfDoCp62DLlwLR4563ZgNFmfPk8j9mhYja+KtX8=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/promise-spawn/-/promise-spawn-3.0.0.tgz";
        };
        ident = "@npmcli/promise-spawn";
        ltype = "file";
        version = "3.0.0";
      };
    };
    "@npmcli/run-script" = {
      "3.0.3" = {
        depInfo = {
          "@npmcli/node-gyp" = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          "@npmcli/promise-spawn" = {
            descriptor = "^3.0.0";
            pin = "3.0.0";
            runtime = true;
          };
          node-gyp = {
            descriptor = "^8.4.1";
            pin = "8.4.1";
            runtime = true;
          };
          read-package-json-fast = {
            descriptor = "^2.0.3";
            pin = "2.0.3";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-wv3HiROrrXBCITAVxaOns1QyF/w1ZecuhenAi0hkIN4=";
          type = "tarball";
          url = "https://registry.npmjs.org/@npmcli/run-script/-/run-script-3.0.3.tgz";
        };
        ident = "@npmcli/run-script";
        ltype = "file";
        version = "3.0.3";
      };
    };
    "@tootallnate/once" = {
      "1.1.2" = {
        fetchInfo = {
          narHash = "sha256-PuDVi/61es6vfKMXunY8H7aa2xh4hYFAx98PxUrQDk0=";
          type = "tarball";
          url = "https://registry.npmjs.org/@tootallnate/once/-/once-1.1.2.tgz";
        };
        ident = "@tootallnate/once";
        ltype = "file";
        treeInfo = { };
        version = "1.1.2";
      };
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-imdXqP9nQzoswIhPopt3R9FXTR8Hu3wT0ZgBE5jiD8c=";
          type = "tarball";
          url = "https://registry.npmjs.org/@tootallnate/once/-/once-2.0.0.tgz";
        };
        ident = "@tootallnate/once";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    abbrev = {
      "1.1.1" = {
        fetchInfo = {
          narHash = "sha256-yk075w2zPxROzkZzeyrgw2i5oI3QmUM8I8YJ/HKEZgw=";
          type = "tarball";
          url = "https://registry.npmjs.org/abbrev/-/abbrev-1.1.1.tgz";
        };
        ident = "abbrev";
        ltype = "file";
        treeInfo = { };
        version = "1.1.1";
      };
    };
    agent-base = {
      "6.0.2" = {
        depInfo = {
          debug = {
            descriptor = "4";
            pin = "4.3.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-AQld7XJmKIUaV57uNtAsbtxHDp/V8psPWC/xn8srfhE=";
          type = "tarball";
          url = "https://registry.npmjs.org/agent-base/-/agent-base-6.0.2.tgz";
        };
        ident = "agent-base";
        ltype = "file";
        version = "6.0.2";
      };
    };
    agentkeepalive = {
      "4.2.1" = {
        depInfo = {
          debug = {
            descriptor = "^4.1.0";
            pin = "4.3.4";
            runtime = true;
          };
          depd = {
            descriptor = "^1.1.2";
            pin = "1.1.2";
            runtime = true;
          };
          humanize-ms = {
            descriptor = "^1.2.1";
            pin = "1.2.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-8lX5DhkJp2Aa4ed1ZTrLA9REyD1//DRYV6hWOY3f7qk=";
          type = "tarball";
          url = "https://registry.npmjs.org/agentkeepalive/-/agentkeepalive-4.2.1.tgz";
        };
        ident = "agentkeepalive";
        ltype = "file";
        version = "4.2.1";
      };
    };
    aggregate-error = {
      "3.1.0" = {
        depInfo = {
          clean-stack = {
            descriptor = "^2.0.0";
            pin = "2.2.0";
            runtime = true;
          };
          indent-string = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-6e6HGR4f2uXsclbpUzWKV+EHj6+bxMAV0o2y65uBJws=";
          type = "tarball";
          url = "https://registry.npmjs.org/aggregate-error/-/aggregate-error-3.1.0.tgz";
        };
        ident = "aggregate-error";
        ltype = "file";
        version = "3.1.0";
      };
    };
    ansi-regex = {
      "5.0.1" = {
        fetchInfo = {
          narHash = "sha256-8FjueDq8OfpA4/cbcsda1vVcNseZPDYf+YqM56zD03Y=";
          type = "tarball";
          url = "https://registry.npmjs.org/ansi-regex/-/ansi-regex-5.0.1.tgz";
        };
        ident = "ansi-regex";
        ltype = "file";
        treeInfo = { };
        version = "5.0.1";
      };
    };
    aproba = {
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-tHMypoTH0DTXyFngVVjGRKsGfj8V3s33MwGg9LCyEPE=";
          type = "tarball";
          url = "https://registry.npmjs.org/aproba/-/aproba-2.0.0.tgz";
        };
        ident = "aproba";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    are-we-there-yet = {
      "3.0.1" = {
        depInfo = {
          delegates = {
            descriptor = "^1.0.0";
            pin = "1.0.0";
            runtime = true;
          };
          readable-stream = {
            descriptor = "^3.6.0";
            pin = "3.6.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-2sB0sE3v7PLi9E/CCZHM9JMDTS3B9i5DDqWi7Z6Ol3k=";
          type = "tarball";
          url = "https://registry.npmjs.org/are-we-there-yet/-/are-we-there-yet-3.0.1.tgz";
        };
        ident = "are-we-there-yet";
        ltype = "file";
        version = "3.0.1";
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
      "2.0.1" = {
        depInfo = {
          balanced-match = {
            descriptor = "^1.0.0";
            pin = "1.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-aPgI6NNc6Qn7C9eHJmAl8OWaFvBf7tMfn2RlMC/o898=";
          type = "tarball";
          url = "https://registry.npmjs.org/brace-expansion/-/brace-expansion-2.0.1.tgz";
        };
        ident = "brace-expansion";
        ltype = "file";
        version = "2.0.1";
      };
    };
    builtins = {
      "5.0.1" = {
        depInfo = {
          semver = {
            descriptor = "^7.0.0";
            pin = "7.3.8";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-9zWNomp2xLZvtlfjovg0EczcXEfAUiS7wpDmMb33RXI=";
          type = "tarball";
          url = "https://registry.npmjs.org/builtins/-/builtins-5.0.1.tgz";
        };
        ident = "builtins";
        ltype = "file";
        version = "5.0.1";
      };
    };
    cacache = {
      "15.3.0" = {
        depInfo = {
          "@npmcli/fs" = {
            descriptor = "^1.0.0";
            pin = "1.1.1";
            runtime = true;
          };
          "@npmcli/move-file" = {
            descriptor = "^1.0.1";
            pin = "1.1.2";
            runtime = true;
          };
          chownr = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          fs-minipass = {
            descriptor = "^2.0.0";
            pin = "2.1.0";
            runtime = true;
          };
          glob = {
            descriptor = "^7.1.4";
            pin = "7.2.3";
            runtime = true;
          };
          infer-owner = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          lru-cache = {
            descriptor = "^6.0.0";
            pin = "6.0.0";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.1";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-collect = {
            descriptor = "^1.0.2";
            pin = "1.0.2";
            runtime = true;
          };
          minipass-flush = {
            descriptor = "^1.0.5";
            pin = "1.0.5";
            runtime = true;
          };
          minipass-pipeline = {
            descriptor = "^1.2.2";
            pin = "1.2.4";
            runtime = true;
          };
          mkdirp = {
            descriptor = "^1.0.3";
            pin = "1.0.4";
            runtime = true;
          };
          p-map = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
          promise-inflight = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
          ssri = {
            descriptor = "^8.0.1";
            pin = "8.0.1";
            runtime = true;
          };
          tar = {
            descriptor = "^6.0.2";
            pin = "6.1.13";
            runtime = true;
          };
          unique-filename = {
            descriptor = "^1.1.1";
            pin = "1.1.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-2asHt93lVa5OeAXPrhV8QqPgfDQ6n/uSrkteo/fVQ50=";
          type = "tarball";
          url = "https://registry.npmjs.org/cacache/-/cacache-15.3.0.tgz";
        };
        ident = "cacache";
        ltype = "file";
        version = "15.3.0";
      };
      "16.1.3" = {
        depInfo = {
          "@npmcli/fs" = {
            descriptor = "^2.1.0";
            pin = "2.1.2";
            runtime = true;
          };
          "@npmcli/move-file" = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
          chownr = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          fs-minipass = {
            descriptor = "^2.1.0";
            pin = "2.1.0";
            runtime = true;
          };
          glob = {
            descriptor = "^8.0.1";
            pin = "8.1.0";
            runtime = true;
          };
          infer-owner = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          lru-cache = {
            descriptor = "^7.7.1";
            pin = "7.14.1";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.6";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-collect = {
            descriptor = "^1.0.2";
            pin = "1.0.2";
            runtime = true;
          };
          minipass-flush = {
            descriptor = "^1.0.5";
            pin = "1.0.5";
            runtime = true;
          };
          minipass-pipeline = {
            descriptor = "^1.2.4";
            pin = "1.2.4";
            runtime = true;
          };
          mkdirp = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          p-map = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
          promise-inflight = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
          ssri = {
            descriptor = "^9.0.0";
            pin = "9.0.1";
            runtime = true;
          };
          tar = {
            descriptor = "^6.1.11";
            pin = "6.1.13";
            runtime = true;
          };
          unique-filename = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-emielGJJkuXr1aMr/HcJoQE3iubt+5FfTa9zQvpDBEY=";
          type = "tarball";
          url = "https://registry.npmjs.org/cacache/-/cacache-16.1.3.tgz";
        };
        ident = "cacache";
        ltype = "file";
        version = "16.1.3";
      };
    };
    chownr = {
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-P8fmuhs4prbrmpSYt6OpPLFNZD07GXVnT3yCWoMutkY=";
          type = "tarball";
          url = "https://registry.npmjs.org/chownr/-/chownr-2.0.0.tgz";
        };
        ident = "chownr";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    clean-stack = {
      "2.2.0" = {
        fetchInfo = {
          narHash = "sha256-xuCHcTjuD7QIIYUObyniMxdY6E2A8SWwv2gHZKVJ7Jo=";
          type = "tarball";
          url = "https://registry.npmjs.org/clean-stack/-/clean-stack-2.2.0.tgz";
        };
        ident = "clean-stack";
        ltype = "file";
        treeInfo = { };
        version = "2.2.0";
      };
    };
    color-support = {
      "1.1.3" = {
        binInfo = {
          binPairs = {
            color-support = "bin.js";
          };
        };
        fetchInfo = {
          narHash = "sha256-vZ9L7c+Kd0WtoUgypubQv0rKb6qJx6AjOEILv2W1ZNc=";
          type = "tarball";
          url = "https://registry.npmjs.org/color-support/-/color-support-1.1.3.tgz";
        };
        ident = "color-support";
        ltype = "file";
        treeInfo = { };
        version = "1.1.3";
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
    console-control-strings = {
      "1.1.0" = {
        fetchInfo = {
          narHash = "sha256-A1gJ50/y9X+dl+/votziGfPTaAexpBBaZxdsEqc9o6Y=";
          type = "tarball";
          url = "https://registry.npmjs.org/console-control-strings/-/console-control-strings-1.1.0.tgz";
        };
        ident = "console-control-strings";
        ltype = "file";
        treeInfo = { };
        version = "1.1.0";
      };
    };
    debug = {
      "4.3.4" = {
        depInfo = {
          ms = {
            descriptor = "2.1.2";
            pin = "2.1.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-S6cB3bQG4QiKORndkECqPyzcgJwPgetsh/AcbjSrW3I=";
          type = "tarball";
          url = "https://registry.npmjs.org/debug/-/debug-4.3.4.tgz";
        };
        ident = "debug";
        ltype = "file";
        peerInfo = {
          supports-color = {
            descriptor = "*";
            optional = true;
          };
        };
        version = "4.3.4";
      };
    };
    delegates = {
      "1.0.0" = {
        fetchInfo = {
          narHash = "sha256-Ywqj6RmSWzMRJD5/oxk9aGAuHhCwUHiBWo1himFWKjA=";
          type = "tarball";
          url = "https://registry.npmjs.org/delegates/-/delegates-1.0.0.tgz";
        };
        ident = "delegates";
        ltype = "file";
        treeInfo = { };
        version = "1.0.0";
      };
    };
    depd = {
      "1.1.2" = {
        fetchInfo = {
          narHash = "sha256-/mmHmickQMCJUhJfBGpuSMQhwECyUQ/MUfC6ruC9AhM=";
          type = "tarball";
          url = "https://registry.npmjs.org/depd/-/depd-1.1.2.tgz";
        };
        ident = "depd";
        ltype = "file";
        treeInfo = { };
        version = "1.1.2";
      };
    };
    emoji-regex = {
      "8.0.0" = {
        fetchInfo = {
          narHash = "sha256-WRW3MHslwJkKGL+xt09TThHNLeRiKIcUGIk1j+ewTpc=";
          type = "tarball";
          url = "https://registry.npmjs.org/emoji-regex/-/emoji-regex-8.0.0.tgz";
        };
        ident = "emoji-regex";
        ltype = "file";
        treeInfo = { };
        version = "8.0.0";
      };
    };
    encoding = {
      "0.1.13" = {
        depInfo = {
          iconv-lite = {
            descriptor = "^0.6.2";
            pin = "0.6.3";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-MAzreXe5/aRMilKcvPhyhuN2uoNwHEdnw9Fsb9p8U34=";
          type = "tarball";
          url = "https://registry.npmjs.org/encoding/-/encoding-0.1.13.tgz";
        };
        ident = "encoding";
        ltype = "file";
        version = "0.1.13";
      };
    };
    env-paths = {
      "2.2.1" = {
        fetchInfo = {
          narHash = "sha256-LOuBHhPrx99UQ18s8lcCzuRIhrqKysps3RqSN3AWiDY=";
          type = "tarball";
          url = "https://registry.npmjs.org/env-paths/-/env-paths-2.2.1.tgz";
        };
        ident = "env-paths";
        ltype = "file";
        treeInfo = { };
        version = "2.2.1";
      };
    };
    err-code = {
      "2.0.3" = {
        fetchInfo = {
          narHash = "sha256-Mu74mg7yyf9qrKRkHgAKhVpy/wdxhrE9nGtXaGJy3kI=";
          type = "tarball";
          url = "https://registry.npmjs.org/err-code/-/err-code-2.0.3.tgz";
        };
        ident = "err-code";
        ltype = "file";
        treeInfo = { };
        version = "2.0.3";
      };
    };
    fs-minipass = {
      "2.1.0" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-QwXLMphyJpgEhnYzVy2Zw1BIS/VBU1pDKL7LlpfE5nU=";
          type = "tarball";
          url = "https://registry.npmjs.org/fs-minipass/-/fs-minipass-2.1.0.tgz";
        };
        ident = "fs-minipass";
        ltype = "file";
        version = "2.1.0";
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
    gauge = {
      "4.0.4" = {
        depInfo = {
          aproba = {
            descriptor = "^1.0.3 || ^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          color-support = {
            descriptor = "^1.1.3";
            pin = "1.1.3";
            runtime = true;
          };
          console-control-strings = {
            descriptor = "^1.1.0";
            pin = "1.1.0";
            runtime = true;
          };
          has-unicode = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          signal-exit = {
            descriptor = "^3.0.7";
            pin = "3.0.7";
            runtime = true;
          };
          string-width = {
            descriptor = "^4.2.3";
            pin = "4.2.3";
            runtime = true;
          };
          strip-ansi = {
            descriptor = "^6.0.1";
            pin = "6.0.1";
            runtime = true;
          };
          wide-align = {
            descriptor = "^1.1.5";
            pin = "1.1.5";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-qpWm1ZOxo0q9Ds+kb4QFOAGaJ/sVwOEmiYSuKaVuQNc=";
          type = "tarball";
          url = "https://registry.npmjs.org/gauge/-/gauge-4.0.4.tgz";
        };
        ident = "gauge";
        ltype = "file";
        version = "4.0.4";
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
      "8.1.0" = {
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
            descriptor = "^5.0.1";
            pin = "5.1.6";
            runtime = true;
          };
          once = {
            descriptor = "^1.3.0";
            pin = "1.4.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-JXe+hAzhNibsZnDYAgACb17hsYnrU/ISC2wfTDy5ayc=";
          type = "tarball";
          url = "https://registry.npmjs.org/glob/-/glob-8.1.0.tgz";
        };
        ident = "glob";
        ltype = "file";
        version = "8.1.0";
      };
    };
    graceful-fs = {
      "4.2.10" = {
        fetchInfo = {
          narHash = "sha256-AUh4d+JbA0dSyhYmzx3ijrByR9pa70BABBehjnWiwG0=";
          type = "tarball";
          url = "https://registry.npmjs.org/graceful-fs/-/graceful-fs-4.2.10.tgz";
        };
        ident = "graceful-fs";
        ltype = "file";
        treeInfo = { };
        version = "4.2.10";
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
    has-unicode = {
      "2.0.1" = {
        fetchInfo = {
          narHash = "sha256-Nn77NY5wo5A8+koRIbKljRFHGFcwz7L/ExJqmgt3t3E=";
          type = "tarball";
          url = "https://registry.npmjs.org/has-unicode/-/has-unicode-2.0.1.tgz";
        };
        ident = "has-unicode";
        ltype = "file";
        treeInfo = { };
        version = "2.0.1";
      };
    };
    hosted-git-info = {
      "5.2.1" = {
        depInfo = {
          lru-cache = {
            descriptor = "^7.5.1";
            pin = "7.14.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-O1oU3wu85zvptdhwrWeFs04gTQFZKJWRVq8T3LfFI4A=";
          type = "tarball";
          url = "https://registry.npmjs.org/hosted-git-info/-/hosted-git-info-5.2.1.tgz";
        };
        ident = "hosted-git-info";
        ltype = "file";
        version = "5.2.1";
      };
    };
    http-cache-semantics = {
      "4.1.1" = {
        fetchInfo = {
          narHash = "sha256-ssso8PrqV3AXQl7D/zGNGfYqlSep+vfhmYbtzsUm97o=";
          type = "tarball";
          url = "https://registry.npmjs.org/http-cache-semantics/-/http-cache-semantics-4.1.1.tgz";
        };
        ident = "http-cache-semantics";
        ltype = "file";
        treeInfo = { };
        version = "4.1.1";
      };
    };
    http-proxy-agent = {
      "4.0.1" = {
        depInfo = {
          "@tootallnate/once" = {
            descriptor = "1";
            pin = "1.1.2";
            runtime = true;
          };
          agent-base = {
            descriptor = "6";
            pin = "6.0.2";
            runtime = true;
          };
          debug = {
            descriptor = "4";
            pin = "4.3.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-O0SMclOVpPuhX70iTuX73AeluwsKSDmL3YfuthL5ohM=";
          type = "tarball";
          url = "https://registry.npmjs.org/http-proxy-agent/-/http-proxy-agent-4.0.1.tgz";
        };
        ident = "http-proxy-agent";
        ltype = "file";
        version = "4.0.1";
      };
      "5.0.0" = {
        depInfo = {
          "@tootallnate/once" = {
            descriptor = "2";
            pin = "2.0.0";
            runtime = true;
          };
          agent-base = {
            descriptor = "6";
            pin = "6.0.2";
            runtime = true;
          };
          debug = {
            descriptor = "4";
            pin = "4.3.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-8a7NywPQQPUQ+Vopnfsac/PAkj7rYUthODimqQEN5wE=";
          type = "tarball";
          url = "https://registry.npmjs.org/http-proxy-agent/-/http-proxy-agent-5.0.0.tgz";
        };
        ident = "http-proxy-agent";
        ltype = "file";
        version = "5.0.0";
      };
    };
    https-proxy-agent = {
      "5.0.1" = {
        depInfo = {
          agent-base = {
            descriptor = "6";
            pin = "6.0.2";
            runtime = true;
          };
          debug = {
            descriptor = "4";
            pin = "4.3.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-02M71F+3Y2l1gbLk9upzpL6IU7T0t6cbtIgaQzGFQW8=";
          type = "tarball";
          url = "https://registry.npmjs.org/https-proxy-agent/-/https-proxy-agent-5.0.1.tgz";
        };
        ident = "https-proxy-agent";
        ltype = "file";
        version = "5.0.1";
      };
    };
    humanize-ms = {
      "1.2.1" = {
        depInfo = {
          ms = {
            descriptor = "^2.0.0";
            pin = "2.1.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-x7vcChv+U2bEhLUbKzIjqWvIo639OXoEu0KdELFrvCI=";
          type = "tarball";
          url = "https://registry.npmjs.org/humanize-ms/-/humanize-ms-1.2.1.tgz";
        };
        ident = "humanize-ms";
        ltype = "file";
        version = "1.2.1";
      };
    };
    iconv-lite = {
      "0.6.3" = {
        depInfo = {
          safer-buffer = {
            descriptor = ">= 2.1.2 < 3.0.0";
            pin = "2.1.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-5WTD6wj4xQL0yKVTnCsqIUkbWZ6/A1wPKJeLlMvP6xA=";
          type = "tarball";
          url = "https://registry.npmjs.org/iconv-lite/-/iconv-lite-0.6.3.tgz";
        };
        ident = "iconv-lite";
        ltype = "file";
        version = "0.6.3";
      };
    };
    ignore-walk = {
      "5.0.1" = {
        depInfo = {
          minimatch = {
            descriptor = "^5.0.1";
            pin = "5.1.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-90PC3hlGDSO1hsdtMukdB8Ol6eLZ/WHc5sGUYxlTbtI=";
          type = "tarball";
          url = "https://registry.npmjs.org/ignore-walk/-/ignore-walk-5.0.1.tgz";
        };
        ident = "ignore-walk";
        ltype = "file";
        version = "5.0.1";
      };
    };
    imurmurhash = {
      "0.1.4" = {
        fetchInfo = {
          narHash = "sha256-kQg6DzTfAqCJNsP9gs1WygIi03+4/AGeF43p9h4LH30=";
          type = "tarball";
          url = "https://registry.npmjs.org/imurmurhash/-/imurmurhash-0.1.4.tgz";
        };
        ident = "imurmurhash";
        ltype = "file";
        treeInfo = { };
        version = "0.1.4";
      };
    };
    indent-string = {
      "4.0.0" = {
        fetchInfo = {
          narHash = "sha256-W9b4E+WHsnHAhViCA940yL6iiSaz/wzLiPzdXvX1MXw=";
          type = "tarball";
          url = "https://registry.npmjs.org/indent-string/-/indent-string-4.0.0.tgz";
        };
        ident = "indent-string";
        ltype = "file";
        treeInfo = { };
        version = "4.0.0";
      };
    };
    infer-owner = {
      "1.0.4" = {
        fetchInfo = {
          narHash = "sha256-qsfARJ/KS56KNVx4b3t7tG4OOv1WJRGJArO6lhzlWtM=";
          type = "tarball";
          url = "https://registry.npmjs.org/infer-owner/-/infer-owner-1.0.4.tgz";
        };
        ident = "infer-owner";
        ltype = "file";
        treeInfo = { };
        version = "1.0.4";
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
    ip = {
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-2DDZlTSMc1SzHR9ef9OlHzZUeCThLWIcU3V56F4Zf8k=";
          type = "tarball";
          url = "https://registry.npmjs.org/ip/-/ip-2.0.0.tgz";
        };
        ident = "ip";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
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
    is-fullwidth-code-point = {
      "3.0.0" = {
        fetchInfo = {
          narHash = "sha256-FAwh/1ODBHIw/Tm2EQLvleV6Xkb1qy7AKy6kBEi9ei8=";
          type = "tarball";
          url = "https://registry.npmjs.org/is-fullwidth-code-point/-/is-fullwidth-code-point-3.0.0.tgz";
        };
        ident = "is-fullwidth-code-point";
        ltype = "file";
        treeInfo = { };
        version = "3.0.0";
      };
    };
    is-lambda = {
      "1.0.1" = {
        fetchInfo = {
          narHash = "sha256-9aa077zq3bErmDHDXMRsiP1/safFzjixLxXzC0E0a4k=";
          type = "tarball";
          url = "https://registry.npmjs.org/is-lambda/-/is-lambda-1.0.1.tgz";
        };
        ident = "is-lambda";
        ltype = "file";
        treeInfo = { };
        version = "1.0.1";
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
    json-parse-even-better-errors = {
      "2.3.1" = {
        fetchInfo = {
          narHash = "sha256-JLmbiGbR2cXNIiFjyKZj8WvbNwUEVpADUgztOocgA1s=";
          type = "tarball";
          url = "https://registry.npmjs.org/json-parse-even-better-errors/-/json-parse-even-better-errors-2.3.1.tgz";
        };
        ident = "json-parse-even-better-errors";
        ltype = "file";
        treeInfo = { };
        version = "2.3.1";
      };
    };
    jsonparse = {
      "1.3.1" = {
        fetchInfo = {
          narHash = "sha256-Qsq2UkbP+RhtzyXCykzSPCBHIUw7GdrSockvTFn0qvs=";
          type = "tarball";
          url = "https://registry.npmjs.org/jsonparse/-/jsonparse-1.3.1.tgz";
        };
        ident = "jsonparse";
        ltype = "file";
        treeInfo = { };
        version = "1.3.1";
      };
    };
    lru-cache = {
      "6.0.0" = {
        depInfo = {
          yallist = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-lBc6340YZYAh1Numj5iz418ChtGb3UUtRZLOYj/WJXg=";
          type = "tarball";
          url = "https://registry.npmjs.org/lru-cache/-/lru-cache-6.0.0.tgz";
        };
        ident = "lru-cache";
        ltype = "file";
        version = "6.0.0";
      };
      "7.14.1" = {
        fetchInfo = {
          narHash = "sha256-5cLiIIJOt5ISRCd0Ch4+ALCwevkP5haTpPW0ZviAATc=";
          type = "tarball";
          url = "https://registry.npmjs.org/lru-cache/-/lru-cache-7.14.1.tgz";
        };
        ident = "lru-cache";
        ltype = "file";
        treeInfo = { };
        version = "7.14.1";
      };
    };
    make-fetch-happen = {
      "10.2.1" = {
        depInfo = {
          agentkeepalive = {
            descriptor = "^4.2.1";
            pin = "4.2.1";
            runtime = true;
          };
          cacache = {
            descriptor = "^16.1.0";
            pin = "16.1.3";
            runtime = true;
          };
          http-cache-semantics = {
            descriptor = "^4.1.0";
            pin = "4.1.1";
            runtime = true;
          };
          http-proxy-agent = {
            descriptor = "^5.0.0";
            pin = "5.0.0";
            runtime = true;
          };
          https-proxy-agent = {
            descriptor = "^5.0.0";
            pin = "5.0.1";
            runtime = true;
          };
          is-lambda = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          lru-cache = {
            descriptor = "^7.7.1";
            pin = "7.14.1";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.6";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-collect = {
            descriptor = "^1.0.2";
            pin = "1.0.2";
            runtime = true;
          };
          minipass-fetch = {
            descriptor = "^2.0.3";
            pin = "2.1.2";
            runtime = true;
          };
          minipass-flush = {
            descriptor = "^1.0.5";
            pin = "1.0.5";
            runtime = true;
          };
          minipass-pipeline = {
            descriptor = "^1.2.4";
            pin = "1.2.4";
            runtime = true;
          };
          negotiator = {
            descriptor = "^0.6.3";
            pin = "0.6.3";
            runtime = true;
          };
          promise-retry = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          socks-proxy-agent = {
            descriptor = "^7.0.0";
            pin = "7.0.0";
            runtime = true;
          };
          ssri = {
            descriptor = "^9.0.0";
            pin = "9.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-EBiQu9k8Bi6UGFht6hT7XDlqz5JFd4SsI3MO5qxsTGM=";
          type = "tarball";
          url = "https://registry.npmjs.org/make-fetch-happen/-/make-fetch-happen-10.2.1.tgz";
        };
        ident = "make-fetch-happen";
        ltype = "file";
        version = "10.2.1";
      };
      "9.1.0" = {
        depInfo = {
          agentkeepalive = {
            descriptor = "^4.1.3";
            pin = "4.2.1";
            runtime = true;
          };
          cacache = {
            descriptor = "^15.2.0";
            pin = "15.3.0";
            runtime = true;
          };
          http-cache-semantics = {
            descriptor = "^4.1.0";
            pin = "4.1.1";
            runtime = true;
          };
          http-proxy-agent = {
            descriptor = "^4.0.1";
            pin = "4.0.1";
            runtime = true;
          };
          https-proxy-agent = {
            descriptor = "^5.0.0";
            pin = "5.0.1";
            runtime = true;
          };
          is-lambda = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          lru-cache = {
            descriptor = "^6.0.0";
            pin = "6.0.0";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.3";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-collect = {
            descriptor = "^1.0.2";
            pin = "1.0.2";
            runtime = true;
          };
          minipass-fetch = {
            descriptor = "^1.3.2";
            pin = "1.4.1";
            runtime = true;
          };
          minipass-flush = {
            descriptor = "^1.0.5";
            pin = "1.0.5";
            runtime = true;
          };
          minipass-pipeline = {
            descriptor = "^1.2.4";
            pin = "1.2.4";
            runtime = true;
          };
          negotiator = {
            descriptor = "^0.6.2";
            pin = "0.6.3";
            runtime = true;
          };
          promise-retry = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          socks-proxy-agent = {
            descriptor = "^6.0.0";
            pin = "6.2.1";
            runtime = true;
          };
          ssri = {
            descriptor = "^8.0.0";
            pin = "8.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-meDMcu4Aw9tZiLm7g2EeqtcZy5ESODQkNgZNuT2ccxk=";
          type = "tarball";
          url = "https://registry.npmjs.org/make-fetch-happen/-/make-fetch-happen-9.1.0.tgz";
        };
        ident = "make-fetch-happen";
        ltype = "file";
        version = "9.1.0";
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
      "5.1.6" = {
        depInfo = {
          brace-expansion = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-IppUfUFv/Auepn6lv23SdcaxJOCK1CjBOmFjJXeK8Vs=";
          type = "tarball";
          url = "https://registry.npmjs.org/minimatch/-/minimatch-5.1.6.tgz";
        };
        ident = "minimatch";
        ltype = "file";
        version = "5.1.6";
      };
    };
    minipass = {
      "3.3.6" = {
        depInfo = {
          yallist = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-IH/N0VNqip1fgncrPr+6JTsU4PagYbuMXMhmGkZeM2E=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass/-/minipass-3.3.6.tgz";
        };
        ident = "minipass";
        ltype = "file";
        version = "3.3.6";
      };
      "4.0.1" = {
        fetchInfo = {
          narHash = "sha256-REsjDAXqB43nIZXdNf/AVYPWb0JVt+sZsnztGwAVJ3c=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass/-/minipass-4.0.1.tgz";
        };
        ident = "minipass";
        ltype = "file";
        treeInfo = { };
        version = "4.0.1";
      };
    };
    minipass-collect = {
      "1.0.2" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-aGeUFFUmngD+NCgDrtang/j4T0lUoM+D7Vx+EcvMKB8=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-collect/-/minipass-collect-1.0.2.tgz";
        };
        ident = "minipass-collect";
        ltype = "file";
        version = "1.0.2";
      };
    };
    minipass-fetch = {
      "1.4.1" = {
        depInfo = {
          encoding = {
            descriptor = "^0.1.12";
            optional = true;
            pin = "0.1.13";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.0";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-sized = {
            descriptor = "^1.0.3";
            pin = "1.0.3";
            runtime = true;
          };
          minizlib = {
            descriptor = "^2.0.0";
            pin = "2.1.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-6UwtKQYhg2NIhuhvPVoY1YAwBtWmL53QT0PybQ/MgiY=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-fetch/-/minipass-fetch-1.4.1.tgz";
        };
        ident = "minipass-fetch";
        ltype = "file";
        version = "1.4.1";
      };
      "2.1.2" = {
        depInfo = {
          encoding = {
            descriptor = "^0.1.13";
            optional = true;
            pin = "0.1.13";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.6";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-sized = {
            descriptor = "^1.0.3";
            pin = "1.0.3";
            runtime = true;
          };
          minizlib = {
            descriptor = "^2.1.2";
            pin = "2.1.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-7yy+z2KOhxnK/qvEcdUmWg/yEukUBcM7Mr6I6agNi8g=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-fetch/-/minipass-fetch-2.1.2.tgz";
        };
        ident = "minipass-fetch";
        ltype = "file";
        version = "2.1.2";
      };
    };
    minipass-flush = {
      "1.0.5" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-W9Q6ydEgCsNddtC7HFPlcNyjn1slLuX9kox1ckJHLgw=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-flush/-/minipass-flush-1.0.5.tgz";
        };
        ident = "minipass-flush";
        ltype = "file";
        version = "1.0.5";
      };
    };
    minipass-json-stream = {
      "1.0.1" = {
        depInfo = {
          jsonparse = {
            descriptor = "^1.3.1";
            pin = "1.3.1";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-QdOVuFjK6JEyszJfYd9KhCuQbzg/mkQxu2ejBnrw29o=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-json-stream/-/minipass-json-stream-1.0.1.tgz";
        };
        ident = "minipass-json-stream";
        ltype = "file";
        version = "1.0.1";
      };
    };
    minipass-pipeline = {
      "1.2.4" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-IN08aDTxhlMOrhne44r0a7akG3u8PO6y4Rh4NNFqyvY=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-pipeline/-/minipass-pipeline-1.2.4.tgz";
        };
        ident = "minipass-pipeline";
        ltype = "file";
        version = "1.2.4";
      };
    };
    minipass-sized = {
      "1.0.3" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-bpGKs0xmPKPQXWQmmfdxxpCsnytlGrgQZC47HExv8/8=";
          type = "tarball";
          url = "https://registry.npmjs.org/minipass-sized/-/minipass-sized-1.0.3.tgz";
        };
        ident = "minipass-sized";
        ltype = "file";
        version = "1.0.3";
      };
    };
    minizlib = {
      "2.1.2" = {
        depInfo = {
          minipass = {
            descriptor = "^3.0.0";
            pin = "3.3.6";
            runtime = true;
          };
          yallist = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-wTrwx8sskCvs9IpE4tRWg3B/4t+nZUGwwIe68dIutmY=";
          type = "tarball";
          url = "https://registry.npmjs.org/minizlib/-/minizlib-2.1.2.tgz";
        };
        ident = "minizlib";
        ltype = "file";
        version = "2.1.2";
      };
    };
    mkdirp = {
      "1.0.4" = {
        binInfo = {
          binPairs = {
            mkdirp = "bin/cmd.js";
          };
        };
        fetchInfo = {
          narHash = "sha256-FsQ8klkGEeQftp/5a3F9KrZPqo9wpR1tuRwqS9WTDxU=";
          type = "tarball";
          url = "https://registry.npmjs.org/mkdirp/-/mkdirp-1.0.4.tgz";
        };
        ident = "mkdirp";
        ltype = "file";
        treeInfo = { };
        version = "1.0.4";
      };
    };
    ms = {
      "2.1.2" = {
        fetchInfo = {
          narHash = "sha256-Y87ut99BMamY3YJBX3Cj3DvOJWkqW+7MrPm7bLyuT50=";
          type = "tarball";
          url = "https://registry.npmjs.org/ms/-/ms-2.1.2.tgz";
        };
        ident = "ms";
        ltype = "file";
        treeInfo = { };
        version = "2.1.2";
      };
    };
    negotiator = {
      "0.6.3" = {
        fetchInfo = {
          narHash = "sha256-DUoNvtWFVWjTl64o46Lz1IqWVQA+AUtnsufCUJ6d1F8=";
          type = "tarball";
          url = "https://registry.npmjs.org/negotiator/-/negotiator-0.6.3.tgz";
        };
        ident = "negotiator";
        ltype = "file";
        treeInfo = { };
        version = "0.6.3";
      };
    };
    node-gyp = {
      "8.4.1" = {
        binInfo = {
          binPairs = {
            node-gyp = "bin/node-gyp.js";
          };
        };
        depInfo = {
          env-paths = {
            descriptor = "^2.2.0";
            pin = "2.2.1";
            runtime = true;
          };
          glob = {
            descriptor = "^7.1.4";
            pin = "7.2.3";
            runtime = true;
          };
          graceful-fs = {
            descriptor = "^4.2.6";
            pin = "4.2.10";
            runtime = true;
          };
          make-fetch-happen = {
            descriptor = "^9.1.0";
            pin = "9.1.0";
            runtime = true;
          };
          nopt = {
            descriptor = "^5.0.0";
            pin = "5.0.0";
            runtime = true;
          };
          npmlog = {
            descriptor = "^6.0.0";
            pin = "6.0.2";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
          tar = {
            descriptor = "^6.1.2";
            pin = "6.1.13";
            runtime = true;
          };
          which = {
            descriptor = "^2.0.2";
            pin = "2.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-pK23vjLmxJ28eWJEQ/YcOyEAQ2lVL07CVq2HtGANg6c=";
          type = "tarball";
          url = "https://registry.npmjs.org/node-gyp/-/node-gyp-8.4.1.tgz";
        };
        ident = "node-gyp";
        ltype = "file";
        version = "8.4.1";
      };
    };
    nopt = {
      "5.0.0" = {
        binInfo = {
          binPairs = {
            nopt = "bin/nopt.js";
          };
        };
        depInfo = {
          abbrev = {
            descriptor = "1";
            pin = "1.1.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-V8Sa0wPxhzKmkBC2vyDOXRz7eL4Bn8UnjYE3S061Pzk=";
          type = "tarball";
          url = "https://registry.npmjs.org/nopt/-/nopt-5.0.0.tgz";
        };
        ident = "nopt";
        ltype = "file";
        version = "5.0.0";
      };
    };
    normalize-package-data = {
      "4.0.1" = {
        depInfo = {
          hosted-git-info = {
            descriptor = "^5.0.0";
            pin = "5.2.1";
            runtime = true;
          };
          is-core-module = {
            descriptor = "^2.8.1";
            pin = "2.11.0";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
          validate-npm-package-license = {
            descriptor = "^3.0.4";
            pin = "3.0.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-sgfUNX80w6VSUsqpIGAl9RvmcqqNfDuh/f+Qpzxw3O4=";
          type = "tarball";
          url = "https://registry.npmjs.org/normalize-package-data/-/normalize-package-data-4.0.1.tgz";
        };
        ident = "normalize-package-data";
        ltype = "file";
        version = "4.0.1";
      };
    };
    npm-bundled = {
      "1.1.2" = {
        depInfo = {
          npm-normalize-package-bin = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-BC5gAp80McYoqhDm8ckW7mkiT4Rg7st6gqFkxmwIXGs=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-bundled/-/npm-bundled-1.1.2.tgz";
        };
        ident = "npm-bundled";
        ltype = "file";
        version = "1.1.2";
      };
      "2.0.1" = {
        depInfo = {
          npm-normalize-package-bin = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-M17LCwPUHbh4EdtaTzQ/owex3CCgRzB4fa+R2SI8+2g=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-bundled/-/npm-bundled-2.0.1.tgz";
        };
        ident = "npm-bundled";
        ltype = "file";
        version = "2.0.1";
      };
    };
    npm-install-checks = {
      "5.0.0" = {
        depInfo = {
          semver = {
            descriptor = "^7.1.1";
            pin = "7.3.8";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-IjQRzBSdZsg8qnLbs5/mAVcQBaHTn+MNMnzYhhKdzB8=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-install-checks/-/npm-install-checks-5.0.0.tgz";
        };
        ident = "npm-install-checks";
        ltype = "file";
        version = "5.0.0";
      };
    };
    npm-normalize-package-bin = {
      "1.0.1" = {
        fetchInfo = {
          narHash = "sha256-ReXfwCTOnUjQpBJGXkgxFldWyS3eYnErDJKsGsw7Ypk=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-normalize-package-bin/-/npm-normalize-package-bin-1.0.1.tgz";
        };
        ident = "npm-normalize-package-bin";
        ltype = "file";
        treeInfo = { };
        version = "1.0.1";
      };
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-6FmqLBnCxjDB98lbimfRPZH7H8vk/K+jBvpZujQ760w=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-normalize-package-bin/-/npm-normalize-package-bin-2.0.0.tgz";
        };
        ident = "npm-normalize-package-bin";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    npm-package-arg = {
      "9.1.2" = {
        depInfo = {
          hosted-git-info = {
            descriptor = "^5.0.0";
            pin = "5.2.1";
            runtime = true;
          };
          proc-log = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
          validate-npm-package-name = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-Xj0y5lD1v7mXlK8UrItBbqypGiRI2JJ9hrSgy1M3Ikk=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-package-arg/-/npm-package-arg-9.1.2.tgz";
        };
        ident = "npm-package-arg";
        ltype = "file";
        version = "9.1.2";
      };
    };
    npm-packlist = {
      "5.1.3" = {
        binInfo = {
          binPairs = {
            npm-packlist = "bin/index.js";
          };
        };
        depInfo = {
          glob = {
            descriptor = "^8.0.1";
            pin = "8.1.0";
            runtime = true;
          };
          ignore-walk = {
            descriptor = "^5.0.1";
            pin = "5.0.1";
            runtime = true;
          };
          npm-bundled = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
          npm-normalize-package-bin = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-6UVanKyHpUx6naMX0b+CyT1jMeWr7ZsZ4TnUeUNa6A0=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-packlist/-/npm-packlist-5.1.3.tgz";
        };
        ident = "npm-packlist";
        ltype = "file";
        version = "5.1.3";
      };
    };
    npm-pick-manifest = {
      "7.0.2" = {
        depInfo = {
          npm-install-checks = {
            descriptor = "^5.0.0";
            pin = "5.0.0";
            runtime = true;
          };
          npm-normalize-package-bin = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          npm-package-arg = {
            descriptor = "^9.0.0";
            pin = "9.1.2";
            runtime = true;
          };
          semver = {
            descriptor = "^7.3.5";
            pin = "7.3.8";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-sIJHKFvtZEnoKNTqHY599OXJmAIuUw6UMyX10R/jEkc=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-pick-manifest/-/npm-pick-manifest-7.0.2.tgz";
        };
        ident = "npm-pick-manifest";
        ltype = "file";
        version = "7.0.2";
      };
    };
    npm-registry-fetch = {
      "13.3.1" = {
        depInfo = {
          make-fetch-happen = {
            descriptor = "^10.0.6";
            pin = "10.2.1";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.6";
            pin = "3.3.6";
            runtime = true;
          };
          minipass-fetch = {
            descriptor = "^2.0.3";
            pin = "2.1.2";
            runtime = true;
          };
          minipass-json-stream = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
          minizlib = {
            descriptor = "^2.1.2";
            pin = "2.1.2";
            runtime = true;
          };
          npm-package-arg = {
            descriptor = "^9.0.1";
            pin = "9.1.2";
            runtime = true;
          };
          proc-log = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-HJnfnbQOIvpVKG2BkHI9ixyQZLhjql3YAhzo9uMExlM=";
          type = "tarball";
          url = "https://registry.npmjs.org/npm-registry-fetch/-/npm-registry-fetch-13.3.1.tgz";
        };
        ident = "npm-registry-fetch";
        ltype = "file";
        version = "13.3.1";
      };
    };
    npmlog = {
      "6.0.2" = {
        depInfo = {
          are-we-there-yet = {
            descriptor = "^3.0.0";
            pin = "3.0.1";
            runtime = true;
          };
          console-control-strings = {
            descriptor = "^1.1.0";
            pin = "1.1.0";
            runtime = true;
          };
          gauge = {
            descriptor = "^4.0.3";
            pin = "4.0.4";
            runtime = true;
          };
          set-blocking = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-4byd5uuapLd0pGp7vP32YcOpmnU9d+XEnJLXca27kf8=";
          type = "tarball";
          url = "https://registry.npmjs.org/npmlog/-/npmlog-6.0.2.tgz";
        };
        ident = "npmlog";
        ltype = "file";
        version = "6.0.2";
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
    p-map = {
      "4.0.0" = {
        depInfo = {
          aggregate-error = {
            descriptor = "^3.0.0";
            pin = "3.1.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-9kfDIj1LTyKMJ7yg8yRhsheTUfd4laq4opkCXSMvd1U=";
          type = "tarball";
          url = "https://registry.npmjs.org/p-map/-/p-map-4.0.0.tgz";
        };
        ident = "p-map";
        ltype = "file";
        version = "4.0.0";
      };
    };
    pacote = {
      "13.3.0" = {
        binInfo = {
          binPairs = {
            pacote = "lib/bin.js";
          };
        };
        depInfo = {
          "@npmcli/git" = {
            descriptor = "^3.0.0";
            pin = "3.0.2";
            runtime = true;
          };
          "@npmcli/installed-package-contents" = {
            descriptor = "^1.0.7";
            pin = "1.0.7";
            runtime = true;
          };
          "@npmcli/promise-spawn" = {
            descriptor = "^3.0.0";
            pin = "3.0.0";
            runtime = true;
          };
          "@npmcli/run-script" = {
            descriptor = "^3.0.1";
            pin = "3.0.3";
            runtime = true;
          };
          cacache = {
            descriptor = "^16.0.0";
            pin = "16.1.3";
            runtime = true;
          };
          chownr = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          fs-minipass = {
            descriptor = "^2.1.0";
            pin = "2.1.0";
            runtime = true;
          };
          infer-owner = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          minipass = {
            descriptor = "^3.1.6";
            pin = "3.3.6";
            runtime = true;
          };
          mkdirp = {
            descriptor = "^1.0.4";
            pin = "1.0.4";
            runtime = true;
          };
          npm-package-arg = {
            descriptor = "^9.0.0";
            pin = "9.1.2";
            runtime = true;
          };
          npm-packlist = {
            descriptor = "^5.0.0";
            pin = "5.1.3";
            runtime = true;
          };
          npm-pick-manifest = {
            descriptor = "^7.0.0";
            pin = "7.0.2";
            runtime = true;
          };
          npm-registry-fetch = {
            descriptor = "^13.0.1";
            pin = "13.3.1";
            runtime = true;
          };
          proc-log = {
            descriptor = "^2.0.0";
            pin = "2.0.1";
            runtime = true;
          };
          promise-retry = {
            descriptor = "^2.0.1";
            pin = "2.0.1";
            runtime = true;
          };
          read-package-json = {
            descriptor = "^5.0.0";
            pin = "5.0.2";
            runtime = true;
          };
          read-package-json-fast = {
            descriptor = "^2.0.3";
            pin = "2.0.3";
            runtime = true;
          };
          rimraf = {
            descriptor = "^3.0.2";
            pin = "3.0.2";
            runtime = true;
          };
          ssri = {
            descriptor = "^9.0.0";
            pin = "9.0.1";
            runtime = true;
          };
          tar = {
            descriptor = "^6.1.11";
            pin = "6.1.13";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-RN8gBXHMJ9sekHLlVFBYhRf5iziJDFWmAxKw5mlAswA=";
          type = "tarball";
          url = "https://registry.npmjs.org/pacote/-/pacote-13.3.0.tgz";
        };
        ident = "pacote";
        ltype = "file";
        version = "13.3.0";
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
    proc-log = {
      "2.0.1" = {
        fetchInfo = {
          narHash = "sha256-TYre/Z+1bczpVQD2wkoepDAs7JLUdq1fvjZaewsQaKo=";
          type = "tarball";
          url = "https://registry.npmjs.org/proc-log/-/proc-log-2.0.1.tgz";
        };
        ident = "proc-log";
        ltype = "file";
        treeInfo = { };
        version = "2.0.1";
      };
    };
    promise-inflight = {
      "1.0.1" = {
        fetchInfo = {
          narHash = "sha256-XV8M3LYInv6Vpkkw1pPu7EwW3rny87h6tRiZAEYLkz4=";
          type = "tarball";
          url = "https://registry.npmjs.org/promise-inflight/-/promise-inflight-1.0.1.tgz";
        };
        ident = "promise-inflight";
        ltype = "file";
        treeInfo = { };
        version = "1.0.1";
      };
    };
    promise-retry = {
      "2.0.1" = {
        depInfo = {
          err-code = {
            descriptor = "^2.0.2";
            pin = "2.0.3";
            runtime = true;
          };
          retry = {
            descriptor = "^0.12.0";
            pin = "0.12.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-dNrmMImqAzbT+4Vt7Qg5tBQ5m2wy1SAShhLkY55nkP8=";
          type = "tarball";
          url = "https://registry.npmjs.org/promise-retry/-/promise-retry-2.0.1.tgz";
        };
        ident = "promise-retry";
        ltype = "file";
        version = "2.0.1";
      };
    };
    read-package-json = {
      "5.0.2" = {
        depInfo = {
          glob = {
            descriptor = "^8.0.1";
            pin = "8.1.0";
            runtime = true;
          };
          json-parse-even-better-errors = {
            descriptor = "^2.3.1";
            pin = "2.3.1";
            runtime = true;
          };
          normalize-package-data = {
            descriptor = "^4.0.0";
            pin = "4.0.1";
            runtime = true;
          };
          npm-normalize-package-bin = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-DbEYUCND6pejBC+45kMpBbFPZsPIr38uylM9StI7GBY=";
          type = "tarball";
          url = "https://registry.npmjs.org/read-package-json/-/read-package-json-5.0.2.tgz";
        };
        ident = "read-package-json";
        ltype = "file";
        version = "5.0.2";
      };
    };
    read-package-json-fast = {
      "2.0.3" = {
        depInfo = {
          json-parse-even-better-errors = {
            descriptor = "^2.3.0";
            pin = "2.3.1";
            runtime = true;
          };
          npm-normalize-package-bin = {
            descriptor = "^1.0.1";
            pin = "1.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-L6EaJgpQmiqmMr4KHZXMITEJ5FoU7LP7561KR/spZN8=";
          type = "tarball";
          url = "https://registry.npmjs.org/read-package-json-fast/-/read-package-json-fast-2.0.3.tgz";
        };
        ident = "read-package-json-fast";
        ltype = "file";
        version = "2.0.3";
      };
    };
    readable-stream = {
      "3.6.0" = {
        depInfo = {
          inherits = {
            descriptor = "^2.0.3";
            pin = "2.0.4";
            runtime = true;
          };
          string_decoder = {
            descriptor = "^1.1.1";
            pin = "1.3.0";
            runtime = true;
          };
          util-deprecate = {
            descriptor = "^1.0.1";
            pin = "1.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-pvwBMxYeE5paPfTTAXnvO9IJIEcvBww9FyIr95bDA7Y=";
          type = "tarball";
          url = "https://registry.npmjs.org/readable-stream/-/readable-stream-3.6.0.tgz";
        };
        ident = "readable-stream";
        ltype = "file";
        version = "3.6.0";
      };
    };
    retry = {
      "0.12.0" = {
        fetchInfo = {
          narHash = "sha256-dSPaNLog9TaWiPokeHcz2ZUdkQfvLb0IZC6r92b6VfQ=";
          type = "tarball";
          url = "https://registry.npmjs.org/retry/-/retry-0.12.0.tgz";
        };
        ident = "retry";
        ltype = "file";
        treeInfo = { };
        version = "0.12.0";
      };
    };
    rimraf = {
      "3.0.2" = {
        binInfo = {
          binPairs = {
            rimraf = "bin.js";
          };
        };
        depInfo = {
          glob = {
            descriptor = "^7.1.3";
            pin = "7.2.3";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-5ZflqftTdzdyQtoHawWDKLP29TBYks2sneUZTaH6VJM=";
          type = "tarball";
          url = "https://registry.npmjs.org/rimraf/-/rimraf-3.0.2.tgz";
        };
        ident = "rimraf";
        ltype = "file";
        version = "3.0.2";
      };
    };
    safe-buffer = {
      "5.2.1" = {
        fetchInfo = {
          narHash = "sha256-wXBrp88QpZPUzawZ33OaWsjCtWTVMsflFJRBg2/U4y8=";
          type = "tarball";
          url = "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.2.1.tgz";
        };
        ident = "safe-buffer";
        ltype = "file";
        treeInfo = { };
        version = "5.2.1";
      };
    };
    safer-buffer = {
      "2.1.2" = {
        fetchInfo = {
          narHash = "sha256-3h6PTqFTKFv3m2ETKDUSOB1rI9KcqogKnSfrV1qnJc0=";
          type = "tarball";
          url = "https://registry.npmjs.org/safer-buffer/-/safer-buffer-2.1.2.tgz";
        };
        ident = "safer-buffer";
        ltype = "file";
        treeInfo = { };
        version = "2.1.2";
      };
    };
    semver = {
      "7.3.8" = {
        binInfo = {
          binPairs = {
            semver = "bin/semver.js";
          };
        };
        depInfo = {
          lru-cache = {
            descriptor = "^6.0.0";
            pin = "6.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-vqtjrIFs0Yw18hcdfShdL7BwyzqXdZ+K60Rp3oLNo/A=";
          type = "tarball";
          url = "https://registry.npmjs.org/semver/-/semver-7.3.8.tgz";
        };
        ident = "semver";
        ltype = "file";
        version = "7.3.8";
      };
    };
    set-blocking = {
      "2.0.0" = {
        fetchInfo = {
          narHash = "sha256-v/iCe60xEPwDGC6+iEAS+xvV8ilPSlIyUSmLMfS2bwQ=";
          type = "tarball";
          url = "https://registry.npmjs.org/set-blocking/-/set-blocking-2.0.0.tgz";
        };
        ident = "set-blocking";
        ltype = "file";
        treeInfo = { };
        version = "2.0.0";
      };
    };
    signal-exit = {
      "3.0.7" = {
        fetchInfo = {
          narHash = "sha256-2mSrADWJKHoX/YwLWk/Mdb4mjpL/6QYU8Evqtm24fdE=";
          type = "tarball";
          url = "https://registry.npmjs.org/signal-exit/-/signal-exit-3.0.7.tgz";
        };
        ident = "signal-exit";
        ltype = "file";
        treeInfo = { };
        version = "3.0.7";
      };
    };
    smart-buffer = {
      "4.2.0" = {
        fetchInfo = {
          narHash = "sha256-IUxIDwNI5kPaW5+sqahq2lh6rGvobXK+Ub/4ixdZz+o=";
          type = "tarball";
          url = "https://registry.npmjs.org/smart-buffer/-/smart-buffer-4.2.0.tgz";
        };
        ident = "smart-buffer";
        ltype = "file";
        treeInfo = { };
        version = "4.2.0";
      };
    };
    socks = {
      "2.7.1" = {
        depInfo = {
          ip = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          smart-buffer = {
            descriptor = "^4.2.0";
            pin = "4.2.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-/8rHeSB0iSV5wx9Y34C2+xSSHa3lvF5fMIdUD1d8lXI=";
          type = "tarball";
          url = "https://registry.npmjs.org/socks/-/socks-2.7.1.tgz";
        };
        ident = "socks";
        ltype = "file";
        version = "2.7.1";
      };
    };
    socks-proxy-agent = {
      "6.2.1" = {
        depInfo = {
          agent-base = {
            descriptor = "^6.0.2";
            pin = "6.0.2";
            runtime = true;
          };
          debug = {
            descriptor = "^4.3.3";
            pin = "4.3.4";
            runtime = true;
          };
          socks = {
            descriptor = "^2.6.2";
            pin = "2.7.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-vBwjvYBKyT8spSD0Pfmv1lQsuuZgODtH5o3F0GznFO0=";
          type = "tarball";
          url = "https://registry.npmjs.org/socks-proxy-agent/-/socks-proxy-agent-6.2.1.tgz";
        };
        ident = "socks-proxy-agent";
        ltype = "file";
        version = "6.2.1";
      };
      "7.0.0" = {
        depInfo = {
          agent-base = {
            descriptor = "^6.0.2";
            pin = "6.0.2";
            runtime = true;
          };
          debug = {
            descriptor = "^4.3.3";
            pin = "4.3.4";
            runtime = true;
          };
          socks = {
            descriptor = "^2.6.2";
            pin = "2.7.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-RZBddA4J4WcXpeTGcHl3SmQxxBlkAPp/XcCc0gKpPD8=";
          type = "tarball";
          url = "https://registry.npmjs.org/socks-proxy-agent/-/socks-proxy-agent-7.0.0.tgz";
        };
        ident = "socks-proxy-agent";
        ltype = "file";
        version = "7.0.0";
      };
    };
    spdx-correct = {
      "3.1.1" = {
        depInfo = {
          spdx-expression-parse = {
            descriptor = "^3.0.0";
            pin = "3.0.1";
            runtime = true;
          };
          spdx-license-ids = {
            descriptor = "^3.0.0";
            pin = "3.0.12";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-LRoJS+j5IDHTdE7dudfp5OB6pzaztCGOpJnlR5UzShI=";
          type = "tarball";
          url = "https://registry.npmjs.org/spdx-correct/-/spdx-correct-3.1.1.tgz";
        };
        ident = "spdx-correct";
        ltype = "file";
        version = "3.1.1";
      };
    };
    spdx-exceptions = {
      "2.3.0" = {
        fetchInfo = {
          narHash = "sha256-8oTcNAH2o2kY7XueSX1ZqvtWoUEntJ1X9aqg4Po1uXY=";
          type = "tarball";
          url = "https://registry.npmjs.org/spdx-exceptions/-/spdx-exceptions-2.3.0.tgz";
        };
        ident = "spdx-exceptions";
        ltype = "file";
        treeInfo = { };
        version = "2.3.0";
      };
    };
    spdx-expression-parse = {
      "3.0.1" = {
        depInfo = {
          spdx-exceptions = {
            descriptor = "^2.1.0";
            pin = "2.3.0";
            runtime = true;
          };
          spdx-license-ids = {
            descriptor = "^3.0.0";
            pin = "3.0.12";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-LCMRuYaQjyV+uyE5y4d4HaBpVpGuyU9x7jQwRoJB/QU=";
          type = "tarball";
          url = "https://registry.npmjs.org/spdx-expression-parse/-/spdx-expression-parse-3.0.1.tgz";
        };
        ident = "spdx-expression-parse";
        ltype = "file";
        version = "3.0.1";
      };
    };
    spdx-license-ids = {
      "3.0.12" = {
        fetchInfo = {
          narHash = "sha256-lmmikT/gYSLHSJruZI9Ljr5XT7pglk6rh6cx/Hq/BCc=";
          type = "tarball";
          url = "https://registry.npmjs.org/spdx-license-ids/-/spdx-license-ids-3.0.12.tgz";
        };
        ident = "spdx-license-ids";
        ltype = "file";
        treeInfo = { };
        version = "3.0.12";
      };
    };
    ssri = {
      "8.0.1" = {
        depInfo = {
          minipass = {
            descriptor = "^3.1.1";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-oQEI1+TC6rhwrGO891nY5S6GxRL9QGlBDbMOmUl0RIU=";
          type = "tarball";
          url = "https://registry.npmjs.org/ssri/-/ssri-8.0.1.tgz";
        };
        ident = "ssri";
        ltype = "file";
        version = "8.0.1";
      };
      "9.0.1" = {
        depInfo = {
          minipass = {
            descriptor = "^3.1.1";
            pin = "3.3.6";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-qWhpG6QjJSwk2d7vgQ9s41otllikZ2FtdaJdCUDoCWY=";
          type = "tarball";
          url = "https://registry.npmjs.org/ssri/-/ssri-9.0.1.tgz";
        };
        ident = "ssri";
        ltype = "file";
        version = "9.0.1";
      };
    };
    string-width = {
      "4.2.3" = {
        depInfo = {
          emoji-regex = {
            descriptor = "^8.0.0";
            pin = "8.0.0";
            runtime = true;
          };
          is-fullwidth-code-point = {
            descriptor = "^3.0.0";
            pin = "3.0.0";
            runtime = true;
          };
          strip-ansi = {
            descriptor = "^6.0.1";
            pin = "6.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-UkdpzgZbqh+d2lMxcCqdnxter5D6KYGgaYMta2Dhqn4=";
          type = "tarball";
          url = "https://registry.npmjs.org/string-width/-/string-width-4.2.3.tgz";
        };
        ident = "string-width";
        ltype = "file";
        version = "4.2.3";
      };
    };
    string_decoder = {
      "1.3.0" = {
        depInfo = {
          safe-buffer = {
            descriptor = "~5.2.0";
            pin = "5.2.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-eazGQAivX9/7FphEMbSzJR9w+AWaAUazWJjVCVdriUY=";
          type = "tarball";
          url = "https://registry.npmjs.org/string_decoder/-/string_decoder-1.3.0.tgz";
        };
        ident = "string_decoder";
        ltype = "file";
        version = "1.3.0";
      };
    };
    strip-ansi = {
      "6.0.1" = {
        depInfo = {
          ansi-regex = {
            descriptor = "^5.0.1";
            pin = "5.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-mMRzEL6fWJXYmQ2ZhRAhnYMcjdNCfvGF3Y7NekoLgXc=";
          type = "tarball";
          url = "https://registry.npmjs.org/strip-ansi/-/strip-ansi-6.0.1.tgz";
        };
        ident = "strip-ansi";
        ltype = "file";
        version = "6.0.1";
      };
    };
    tar = {
      "6.1.13" = {
        depInfo = {
          chownr = {
            descriptor = "^2.0.0";
            pin = "2.0.0";
            runtime = true;
          };
          fs-minipass = {
            descriptor = "^2.0.0";
            pin = "2.1.0";
            runtime = true;
          };
          minipass = {
            descriptor = "^4.0.0";
            pin = "4.0.1";
            runtime = true;
          };
          minizlib = {
            descriptor = "^2.1.1";
            pin = "2.1.2";
            runtime = true;
          };
          mkdirp = {
            descriptor = "^1.0.3";
            pin = "1.0.4";
            runtime = true;
          };
          yallist = {
            descriptor = "^4.0.0";
            pin = "4.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-cVHDHCxuEhY0wn6RqG6fITxs8cCZxpfH8ZoXTysQZVE=";
          type = "tarball";
          url = "https://registry.npmjs.org/tar/-/tar-6.1.13.tgz";
        };
        ident = "tar";
        ltype = "file";
        version = "6.1.13";
      };
    };
    unique-filename = {
      "1.1.1" = {
        depInfo = {
          unique-slug = {
            descriptor = "^2.0.0";
            pin = "2.0.2";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-gWqYPcPboDMP4GKNzj1RUBGN32KD1yWrcdP8mh0gl9g=";
          type = "tarball";
          url = "https://registry.npmjs.org/unique-filename/-/unique-filename-1.1.1.tgz";
        };
        ident = "unique-filename";
        ltype = "file";
        version = "1.1.1";
      };
      "2.0.1" = {
        depInfo = {
          unique-slug = {
            descriptor = "^3.0.0";
            pin = "3.0.0";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-oDyvhs3WyBA5CTblPr9HYJvjY0zHfX+2w9FcQsy6PE8=";
          type = "tarball";
          url = "https://registry.npmjs.org/unique-filename/-/unique-filename-2.0.1.tgz";
        };
        ident = "unique-filename";
        ltype = "file";
        version = "2.0.1";
      };
    };
    unique-slug = {
      "2.0.2" = {
        depInfo = {
          imurmurhash = {
            descriptor = "^0.1.4";
            pin = "0.1.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-62VcWr2HHzj7Z3BXIvqsDE6c+BH5G4dJPvisKKysH8w=";
          type = "tarball";
          url = "https://registry.npmjs.org/unique-slug/-/unique-slug-2.0.2.tgz";
        };
        ident = "unique-slug";
        ltype = "file";
        version = "2.0.2";
      };
      "3.0.0" = {
        depInfo = {
          imurmurhash = {
            descriptor = "^0.1.4";
            pin = "0.1.4";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-ASKDRDp5bziQTLbFUmU3TADM7lvSjCcwpfUjVzmpbLg=";
          type = "tarball";
          url = "https://registry.npmjs.org/unique-slug/-/unique-slug-3.0.0.tgz";
        };
        ident = "unique-slug";
        ltype = "file";
        version = "3.0.0";
      };
    };
    util-deprecate = {
      "1.0.2" = {
        fetchInfo = {
          narHash = "sha256-rIdgRwu72yh5o+nvWoU8FWww1LMLAIKmtv8wPKglaeY=";
          type = "tarball";
          url = "https://registry.npmjs.org/util-deprecate/-/util-deprecate-1.0.2.tgz";
        };
        ident = "util-deprecate";
        ltype = "file";
        treeInfo = { };
        version = "1.0.2";
      };
    };
    validate-npm-package-license = {
      "3.0.4" = {
        depInfo = {
          spdx-correct = {
            descriptor = "^3.0.0";
            pin = "3.1.1";
            runtime = true;
          };
          spdx-expression-parse = {
            descriptor = "^3.0.0";
            pin = "3.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-CNe0POqcC+Wvyftds8P4h4leM1+PYJxbHWYS6Baqecg=";
          type = "tarball";
          url = "https://registry.npmjs.org/validate-npm-package-license/-/validate-npm-package-license-3.0.4.tgz";
        };
        ident = "validate-npm-package-license";
        ltype = "file";
        version = "3.0.4";
      };
    };
    validate-npm-package-name = {
      "4.0.0" = {
        depInfo = {
          builtins = {
            descriptor = "^5.0.0";
            pin = "5.0.1";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-Lalu+wGzmv5I2oWKO8BgNCH8u28RFns8ygeqdTOM4pc=";
          type = "tarball";
          url = "https://registry.npmjs.org/validate-npm-package-name/-/validate-npm-package-name-4.0.0.tgz";
        };
        ident = "validate-npm-package-name";
        ltype = "file";
        version = "4.0.0";
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
    wide-align = {
      "1.1.5" = {
        depInfo = {
          string-width = {
            descriptor = "^1.0.2 || 2 || 3 || 4";
            pin = "4.2.3";
            runtime = true;
          };
        };
        fetchInfo = {
          narHash = "sha256-uHa8iuh3X8Zzmok/1A4ml8nER3SqYaiDysZU2tmzyWY=";
          type = "tarball";
          url = "https://registry.npmjs.org/wide-align/-/wide-align-1.1.5.tgz";
        };
        ident = "wide-align";
        ltype = "file";
        version = "1.1.5";
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
    yallist = {
      "4.0.0" = {
        fetchInfo = {
          narHash = "sha256-JQNNkqswg1ZH4o8PQS2R8WsZWJtv/5R3vRgc4d1vDR0=";
          type = "tarball";
          url = "https://registry.npmjs.org/yallist/-/yallist-4.0.0.tgz";
        };
        ident = "yallist";
        ltype = "file";
        treeInfo = { };
        version = "4.0.0";
      };
    };
  };
}
