# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  node = nt.submodule {
    options.package = lib.mkOption {
      description = lib.mdDoc "Contents of `package.json`";
      type        = nt.raw;
    };
    option.parent = lib.mkOption {
      description = lib.mdDoc "Reference to the parent node (if any)";
      type        = nt.nullOr lib.libfloco.key;
    };
    option.root = lib.mkOption {
      description = lib.mdDoc "Reference to the root node (if any)";
      type        = nt.nullOr lib.libfloco.key;
    };
    option.edgesIn = lib.mkOption {
      description = lib.mdDoc ''
        List of edges from other nodes to this node.
        These are nodes which we "inherit" from our parent.
      '';
      type = lib.libfloco.uniqueListOf nt.raw;
    };
    option.edgesOut = lib.mkOption {
      description = lib.mdDoc ''
        Attrs of edges from this nodes to other node keyed by `ident`s.
        These point to nodes which we depend on, and eventually populate
        the `children` collection.
      '';
      type = nt.attrsOf nt.raw;
    };
    options.overrides = lib.mkOption {
      description = lib.mdDoc ''
        Attrs keyed by `ident` indicating overrides to descriptors which will
        be applied to child nodes.

        This set must be disjoint with `edgesOut`.
      '';
      type = lib.libfloco.specOverrideSet;
    };
    options.children = lib.mkOption {
      description = lib.mdDoc ''
        Attrs of child nodes keyed by `ident`.

        This set represents the final set of nodes which will be used, and is
        formed by resolving `edgesOut` and parent overrides.
      '';
    };
  };


# ---------------------------------------------------------------------------- #

in {

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
