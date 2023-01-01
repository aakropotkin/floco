# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.treeInfo = lib.mkOption {
    description = lib.mdDoc ''
      `node_modules/` trees used for various lifecycle events.
      These declarations are analogous to the `package.*` field found in
      `package-lock.json(v2/3)` files.
      This means that these fields should describe both direct and indirect
      dependencies for the full dependency graph.

      Tree declarations are expected to be pairs of `node_modules/` paths to
      "keys" ( matching the `key` field in its Nix declaration ):
      ```
      {
        "node_modules/@foo/bar"                  = "@foo/bar/1.0.0";
        "node_modules/@foo/bar/node_modules/baz" = "baz/4.2.0";
        ...
      }
      ```

      Arbitrary trees may be defined for use by later builders; but by default
      we expect `prod` to be defined for any `file` ltype packages which
      contain executables or an `install` event, and `dev` to be defined for
      any packages which have a `build` lifecycle event.

      In practice we expect users to explicitly define these fields only for
      targets which they actually intend to create installables from, and we
      recommend using a `package-lock.json(v2/3)` to fill these values.
    '';
    type = nt.submodule {
      freeformType = nt.attrsOf ( nt.attrsOf nt.str );
      options.dev  = lib.mkOption {
        description = ''
          Tree used for pre-distribution phases such as builds, tests, etc.
        '';
        type = nt.attrsOf nt.str;
      };
      options.prod  = lib.mkOption {
        description = lib.mdDoc ''
          Tree used for post-distribution phases such as global installs and
          execution of `[pre|post]install` scripts or `node-gyp` compilation.
        '';
        type = nt.attrsOf nt.str;
      };
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
