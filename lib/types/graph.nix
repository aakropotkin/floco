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

# ---------------------------------------------------------------------------- #

  scopeEnt = nt.submodule {
    options = {
      pin  = lib.libfloco.mkPinOption;
      path = lib.mkOption { type = nt.either nt.str lib.libfloco.relpath; };
    };
  };

  scope = nt.attrsOf scopeEnt;


# ---------------------------------------------------------------------------- #

  # Coerce a `depInfoEnt' colleciton to a `pin' collection.
  pinsFromDepInfo = nt.attrsOf (
    nt.coercedTo ( nt.attrsOf nt.anything ) ( x: x.pin ) lib.libfloco.version
  );


# ---------------------------------------------------------------------------- #

  mkScopeFromDepInfo = path: depInfo: let
    proc = ident: de: {
      path = let
        pre = if path == "" then "node_modules/" else path + "/";
      in de.path or ( pre + ident );
      pin  = de.pin or de;
    };
  in builtins.mapAttrs proc depInfo;

  scopeFromDepInfo = path: let
    fromT = ( nt.attrsOf nt.anything ) // {
      check = x: ( builtins.isAttrs x ) && (
        ! ( builtins.all scopeEnt.check ( builtins.attrValues x ) )
      );
    };
  in nt.coercedTo fromT ( mkScopeFromDepInfo path ) scope;


# ---------------------------------------------------------------------------- #


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
        type    = nt.either nt.str lib.libfloco.relpath;
        default = lib.mkDerivedConfig options.ident ( i: "node_modules/" + i );
      };

      isRoot = lib.mkOption { type = nt.bool; };

      pscope   = lib.mkOption { type = scope; };
      children = lib.mkOption { type = pinsFromDepInfo; default = {}; };
      requires = lib.mkOption {
        type    = scopeFromDepInfo config.path;
        default = {};
      };
      scope = lib.mkOption {
        type    = scopeFromDepInfo config.path;
        default = {};
      };

      referrers = lib.mkOption {
        type = nt.listOf ( nt.submodule {
          options = {
            key  = lib.libfloco.mkKeyOption;
            path = lib.mkOption {
              type = nt.either nt.str lib.libfloco.relpath;
            };
          };
        } );
        default = [];
      };

      props = lib.mkOption {
        type = nt.attrsOf ( nt.submodule {
          freeformType = nt.attrsOf nt.bool;
          options      = {
            optional = lib.mkOption {
              type    = lib.libfloco.boolAll;
              default = false;
            };
            runtime  = lib.mkOption {
              type    = lib.libfloco.boolAny;
              default = false;
            };
            dev = lib.mkOption {
              type    = lib.libfloco.boolAny;
              default = true;
            };
          };
        } );
        default = {};
      };

    };

    config = {
      ident   = lib.mkOptionDefault ( dirOf config.key );
      version = lib.mkOptionDefault ( baseNameOf config.key );
      key     = lib.mkOptionDefault ( config.ident + "/" + config.version );
      isRoot  = lib.mkOptionDefault (
        ! ( lib.hasInfix "node_modules/" config.path )
      );
      pscope = let
        dft = if config.isRoot then {} else {
          ${config.ident} = config.version;
        };
      in lib.mkDefault dft;
      requires = builtins.mapAttrs ( _: lib.mkDefault ) (
        lib.filterAttrs ( di: de:
          ( config.pscope.${di}.pin or null ) == de.pin
        ) config.depInfo
      );
      children = builtins.mapAttrs ( _: lib.mkDefault ) (
        removeAttrs config.depInfo ( builtins.attrNames config.requires )
      );
      scope = lib.mkDefault ( config.pscope // config.children );
    };

  };

  graphNode = nt.submodule graphNodeDeferred;


# ---------------------------------------------------------------------------- #

  treeModuleFromGraphNode = node: let

    pathFor = let
      pre = if node.path == "" then "node_modules/" else
            node.path + "/node_modules/";
    in ident: pre + ident;

    forDep = ident: de: let
      path = de.path or ( pathFor ident );
      pin  = de.pin  or de;
    in {
      name  = path;
      value = {
        inherit ident path;
        version   = pin;
        key       = ident + "/" + pin;
        referrers = [{ inherit (node) key path; }];
        props     = { inherit (node.depInfo.${ident}) optional runtime dev; };
      };
    };

    depModList = let
      union = lib.attrsets.unionOfDisjoint node.requires node.children;
    in lib.mapAttrsToList forDep union;

    childModList = lib.mapAttrsToList ( ident: _: {
      name         = pathFor ident;
      value.pscope = node.scope;
    } ) node.children;

  in {
    imports = [
      { config = builtins.listToAttrs childModList; }
    ];
    config  = builtins.listToAttrs ( depModList ++ [{
      name  = node.path;
      value = removeAttrs node [
        "_export"
        "metaFiles"
        "fsInfo"
        "fetchInfo"
        "sourceInfo"
        "binInfo"
        "deserialized"
        "fetcher"
      ];
    }] );
  };


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


# ---------------------------------------------------------------------------- #

  inherit
    depInfoEnt
    depInfoCore
  ;


# ---------------------------------------------------------------------------- #

  inherit
    scopeEnt
    scope
    scopeFromDepInfo
    mkScopeFromDepInfo
  ;


# ---------------------------------------------------------------------------- #

  inherit
    graphNodeDeferred
    graphNode
    treeModuleFromGraphNode
  ;

  mkGraphNodeOption = lib.mkOption {
    description = lib.mdDoc ''
      A node in a dependency graph.
    '';
    type = graphNode;
  };

  # Ad hoc module evaluation for `graphNode' records.
  mkGraphNode = {
    ident     ? null
  , version   ? null
  , key       ? null
  , depInfo   ? null
  , peerInfo  ? null
  , path      ? null
  , isRoot    ? null
  , pscope    ? null
  , children  ? null
  , requires  ? null
  , referrers ? null
  , props     ? null
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
