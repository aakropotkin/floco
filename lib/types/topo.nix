# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  toposortedDeferred = { config, ... }: {

    options.result = lib.mkOption {
      description = lib.mdDoc ''
        If a topological sort exists.

        This orders nodes such that no node depends on any node that comes later
        in the list.

        If there is no topological sort, due to a cycle, this is set to `null`,
        instead `cycle` and `loop` fields are set.
      '';
      type    = nt.nullOr ( nt.listOf nt.anything );
      default = null;
    };

    options.cycle  = lib.mkOption {
      description = lib.mdDoc ''
        If a topological sort does not exist, this is the FIRST cycle that
        was found.

        This is a list of nodes that form a cycle.
        If this list is empty, then there are no cycles in the graph.
      '';
      type    = nt.listOf nt.anything;
      default = [];
    };

    options.loops = lib.mkOption {
      description = lib.mdDoc ''
        If a topological sort does not exist, this is the FIRST loop that
        was found.

        This holds a list of nodes in `cycle` that were visited more than once
        during DFS which caused processing to terminate.
        Knowing which nodes triggered termination is useful for cycle breaking,
        since these are often good candidates for node merging.

        If this list is empty, then there are no loops in the graph.
      '';
      type    = nt.listOf nt.anything;
      default = [];
    };

    options.isDAG = lib.mkOption {
      description = lib.mdDoc ''
        Whether the graph is a Directed Acyclic Graph ( DAG ).
        This means that the graph has no cycles and is a tree.
      '';
      type = nt.bool;
    };

    config.isDAG = config.cycle == [];

  };


# ---------------------------------------------------------------------------- #

  toposorted = nt.submodule toposortedDeferred;


# ---------------------------------------------------------------------------- #

in {

  inherit
    toposortedDeferred
    toposorted
  ;

  mkToposortedOption = lib.mkOption {
    description = lib.mdDoc ''
      Results of a topological sort as returned by `nixpkgs#lib.toposort`.
    '';
    type = toposorted;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
