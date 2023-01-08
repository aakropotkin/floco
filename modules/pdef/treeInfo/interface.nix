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
      "keys" ( matching the `key` field in its Nix declaration ).

      In practice we expect users to explicitly define this field only for
      targets which they actually intend to create installables from, and we
      recommend using a `package-lock.json(v2/3)` to fill these values.
    '';

    type = nt.nullOr ( nt.attrsOf ( nt.submodule ./single.interface.nix ) );

    default = null;

    example = lib.literalExpression ''
      {
        "node_modules/@foo/bar" = {
          key = "@foo/bar/1.0.0";
          dev = true;
          # ...
        };
        "node_modules/@foo/bar/node_modules/baz" = {
          key = "baz/4.2.0";
          dev = false;
          # ...
        };
        # ...
      }
    '';

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
