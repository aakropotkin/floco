# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

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

  # A primitive form of `depInfo'.
  # This form is not extensible but covers most use cases for graphing.
  depInfoEnt = nt.submodule {
    freeformType = nt.attrsOf nt.bool;
    options = {
      descriptor = lib.mkOption { type = nt.str; default = "*"; };
      pin        = lib.libfloco.mkPinOption;
      optional   = lib.mkOption { type = nt.bool; default = false; };
      runtime    = lib.mkOption { type = nt.bool; default = false; };
      dev        = lib.mkOption { type = nt.bool; default = true; };
    };
  };

  depInfoCore = nt.attrsOf depInfoEnt;

  pinsFromDepInfo = nt.attrsOf (
    nt.coercedTo ( nt.attrsOf nt.anything ) ( x: x.pin ) lib.libfloco.version
  );


  graphNodeDeferred = { config , options , ... }: {
    freeformType = nt.attrsOf nt.anything;
    options      = {
      ident   = lib.libfloco.mkIdentOption;
      version = lib.libfloco.mkVersionOption;
      key     = lib.libfloco.mkKeyOption;

      depInfo = lib.mkOption { type = depInfoCore; default = {}; };

      # A primitive form of `peerInfo'.
      # This form is not extensible but covers most use cases for graphing.
      peerInfo = lib.mkOption {
        type = nt.attrsOf ( nt.submodule {
          options = {
            descriptor = lib.mkOption { type = nt.str;  default = "*"; };
            optional   = lib.mkOption { type = nt.bool; default = false; };
          };
        } );
        default = {};
      };

      path = lib.mkOption {
        type    = nt.either ( nt.str ) lib.libfloco.relpath;
        default = lib.mkDerivedConfig options.ident ( i: "node_modules/" + i );
      };

      isRoot = lib.mkOption { type = nt.bool; };

      pscope   = lib.mkOption { type = pinsFromDepInfo; };
      children = lib.mkOption { type = pinsFromDepInfo; default = {}; };
      requires = lib.mkOption { type = pinsFromDepInfo; default = {}; };
      scope    = lib.mkOption { type = pinsFromDepInfo; default = {}; };

    };

    config = {
      ident   = lib.mkOptionDefault ( dirOf config.key );
      version = lib.mkOptionDefault ( baseNameOf config.key );
      key     = lib.mkOptionDefault ( config.ident + "/" + config.version );
      isRoot  = lib.mkOptionDefault (
        ! ( lib.hasInfix "node_modules/" config.path )
      );
      pscope  = let
        dft = if config.isRoot then {} else {
          ${config.ident} = config.version;
        };
      in lib.mkDefault dft;
      requires = builtins.mapAttrs ( _: lib.mkDefault ) (
        lib.filterAttrs ( di: de: ( config.pscope.${di} or null ) == de.pin )
                        config.depInfo
      );
      children = builtins.mapAttrs ( _: lib.mkDefault ) (
        removeAttrs config.depInfo ( builtins.attrNames config.requires )
      );
      scope = lib.mkDefault ( config.pscope // config.children );
    };

  };

  graphNode = nt.submodule graphNodeDeferred;


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

  inherit
    depInfoEnt
    depInfoCore
    graphNodeDeferred
    graphNode
  ;

  mkGraphNode = {
    ident    ? null
  , version  ? null
  , key      ? null
  , depInfo  ? null
  , peerInfo ? null
  , path     ? null
  , isRoot   ? null
  , pscope   ? null
  , children ? null
  , requires ? null
  , ...
  } @ config: ( lib.evalModules {
    modules = [graphNodeDeferred { config = config.config or config; }];
  } ).config;

  mkGraphNodeWith = closure: keylike: config: let
    key = if builtins.isString keylike then keylike else
          keylike.key or ( keylike.ident + "/" + keylike.version );
    ident   = keylike.ident or ( dirOf key );
    version = keylike.version or ( baseNameOf key );
    pred    = pdef:
      if pdef ? key then pdef.key == key else
      ( pdef.ident == ident ) && ( pdef.version == version );
    pdef = builtins.head ( builtins.filter pred closure );
  in ( lib.evalModules {
    modules = [
      graphNodeDeferred
      { config = pdef; }
      { config = config.config or config; }
    ];
  } ).config;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
