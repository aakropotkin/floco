# ============================================================================ #
#
# Information concerning `peerDependencies' or "propagated dependencies".
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdef/peerInfo/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {
    peerInfo = lib.mkOption {
      description = lib.mdDoc ''
        Set of propagated dependencies that consumers of this package/module
        must provide at runtime.

        Often peer dependencies are used to enforce interface alignment across
        a set of modules but do not necessarily imply that the requestor depends
        on the declared peer at build time or runtime - rather it states
        "my consumers depend on the declared peer as a side effect of their
        dependence on me".

        NOTE: For the purposes of `treeInfo` and the construction of a
        `node_modules/` tree, if a module declares a peer then that peer must
        be placed in a "sibling" or parent `node_modules/` directory, and never
        as a subdirectory of the requestor!
        The "sibling" case is why the term "peer" is used, indicating that these
        modules must be "peers" living in the same `node_modules/` directory;
        in practice a parent directory also works, but you get the idea.
      '';
      type = nt.attrsOf ( nt.submoduleWith {
        modules = [./single.interface.nix];
      } );
      default = {};
    };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
