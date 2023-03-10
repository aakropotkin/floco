# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  treePath = let
    emptyStr = ( nt.enum [""] ) // {
      name        = "emptyStr";
      description = "empty string";
    };
    treeRelPath = ( nt.strMatching "[^./][^./]?.*" ) // {
      name        = "treePath";
      description = "node_modules tree path";
    };
  in nt.either emptyStr treeRelPath;

  mkTreePathOption = lib.mkOption {
    description = lib.mdDoc ''
      A `node_modules/*` tree path.
      Either the empty string, or a relative path with no leading "./" part.
    '';
    type    = treePath;
    default = "";
  };


# ---------------------------------------------------------------------------- #

  scopeEnt = nt.submodule {
    options = {
      pin  = lib.libfloco.mkPinOption;
      path = lib.libfloco.mkTreePathOption;
      # This would ideally only be defined for strategies which use it, but it's
      # a pain in the ass for those strategies to extend the `scope' submodule
      # type externally so it's easier just to make it available for all
      # strategies as a "nullable" option.
      oneVersion = lib.mkOption {
        description = lib.mdDoc ''
          Indicates that within the closure of the full graph/tree, there is
          only a single version of this module.

          This is useful for various strategies such as "hoisted" which collect
          subtree closures.
          Strategies that have no use for this field can set it to `null`.
        '';
        type    = nt.nullOr nt.bool;
        default = null;
      };
    };
  };

  scope = nt.lazyAttrsOf scopeEnt;

  mkScopeOption = lib.mkOption {
    description = lib.mdDoc ''
      Representation of the `node` resolution scope at a given path.
    '';
    type    = lib.libfloco.scope;
    default = {};
  };


# ---------------------------------------------------------------------------- #

  referrerDeferred = {
    options.key  = lib.libfloco.mkKeyOption;
    options.path = lib.libfloco.mkTreePathOption;
  };

  referrer          = nt.submodule lib.libfloco.referrerDeferred;
  mkReferrersOption = lib.mkOption {
    type    = lib.uniqueListOf lib.libfloco.referrer;
    default = [];
  };


# ---------------------------------------------------------------------------- #

  graphNodeInterfaceDeferred = {
    freeformType = nt.attrsOf nt.anything;
    options      = {
      ident     = lib.libfloco.mkIdentOption;
      version   = lib.libfloco.mkVersionOption;
      key       = lib.libfloco.mkKeyOption;
      depInfo   = lib.libfloco.mkDepInfoBaseOption;
      peerInfo  = lib.libfloco.mkPeerInfoBaseOption;
      path      = lib.libfloco.mkTreePathOption;
      isRoot    = lib.mkOption { type = nt.bool; };
      pscope    = lib.libfloco.mkScopeOption;
      children  = lib.libfloco.mkScopeOption;
      requires  = lib.libfloco.mkScopeOption;
      scope     = lib.libfloco.mkScopeOption;
      referrers = lib.libfloco.mkReferrersOption;
    };  # End `options'
  };

  graphNodeDeferred = {
    config
  , options
  , getChildReqs
  , ...
  }: {
    imports = [lib.libfloco.graphNodeInterfaceDeferred];

    config = let
      cr = getChildReqs {
        inherit (config) ident version path depInfo peerInfo isRoot pscope;
      };
    in {
      _module.args.getChildReqs =
        lib.mkOptionDefault lib.libfloco.getChildReqsBasic;

      ident   = lib.mkOptionDefault ( dirOf config.key );
      version = lib.mkOptionDefault ( baseNameOf config.key );
      key     = lib.mkOptionDefault ( config.ident + "/" + config.version );
      path    = lib.mkOptionDefault ( "node_modules/" + config.ident );
      isRoot  = lib.mkOptionDefault (
        ! ( lib.hasInfix "node_modules/" config.path )
      );
      requires = lib.mkDefault cr.requires;
      children = lib.mkDefault cr.children;
      scope    = lib.mkDefault ( config.pscope // config.children );
    };  # End `config'

  };  # End `graphNodeDeferred'

  graphNode = nt.submodule graphNodeDeferred;

  mkGraphNodeOption = lib.mkOption {
    description = lib.mdDoc ''
      A node in a dependency graph.
    '';
    type = graphNode;
  };


# ---------------------------------------------------------------------------- #

  # collectRefsFromNode :: graphNode -> { <PATH> = [<GNODE-REF>]; ... }
  # -------------------------------------------------------------------
  # Collect "tree level" attrset of refs from a `graphNode' to the modules it
  # consumes as `referrers' members.
  # This is a helper used to generate configs.
  #
  # NOTE: while `requires' always implies a reference, `children' do not.
  # Particularly for "hoisted" strategies, children of a node are not
  # necessarily referenced by their parent.
  # With that in mind we use `depInfo' to reduce `children' to real references.
  collectRefsFromNode = {
    key
  , path
  , requires
  , children
  , depInfo
  , ...
  }: let
    cdeps = builtins.intersectAttrs depInfo children;
    needs = lib.attrsets.unionOfDisjoint requires cdeps;
    proc  = ident: scopeEnt: {
      name            = scopeEnt.path;
      value.referrers = [{ inherit key path; }];
    };
  in lib.mapAttrs' proc needs;


# ---------------------------------------------------------------------------- #

  treeModuleFromGraphNode' = {
    graphNodeModules ? [graphNodeDeferred]
  , getChildReqs     ? null
  , pdefs
  }: { config, ... } @ top: let

    gnMods = let
      gcrMod = if getChildReqs == null then [] else [
        { config._module.args.getChildReqs = lib.mkDefault getChildReqs; }
      ];
      treeEx = { config, ... }: let
        pdef =
          lib.getPdef { inherit pdefs; } { inherit (config) ident version; };
      in { inherit (pdef) depInfo peerInfo; };
    in ( lib.toList graphNodeModules ) ++ gcrMod ++ [treeEx];

  in {

    _file = "<libfloco>/types/graph.nix:treeModuleFromGraphNode'";

    options.tree = lib.mkOption {
      type = nt.lazyAttrsOf ( nt.submodule gnMods );
    };
    options.parent = lib.mkOption {
      type    = nt.nullOr ( nt.submodule gnMods );
      default = null;
    };
    options.node = lib.mkOption {
      type = nt.submodule gnMods;
    };

    config.parent = let
      parentPath = let
        isScoped = ( builtins.substring 0 1 config.ident ) == "@";
        dd       = dirOf ( dirOf config.path );
        p        = if isScoped then dirOf dd else dd;
      in if p == "." then "" else p;
    in lib.mkDefault (
      if config.node.isRoot then null else config.tree.${parentPath}
    );

    config.tree = let
      kids = lib.mapAttrs' ( ident: { pin, path, ... }: {
        name  = path;
        value = {
          inherit ident path;
          version = pin;
          pscope  = config.node.scope;
          isRoot  = false;
        };
      } ) config.node.children;
    in kids // {
      ${config.node.path} = config.node // {
        children = lib.mkForce config.node.children;
        requires = lib.mkForce config.node.requires;
        scope    = lib.mkForce config.node.scope;
        pscope   = lib.mkForce config.node.pscope;
      };
    };

  };  # End `treeModuleFromGraphNode''

  # Collects `treeModuleFromGraphNode'' for children.
  treeModuleClosureOp = {
    graphNodeModules ? [graphNodeDeferred]
  , getChildReqs     ? null
  , pdefs
  } @ args: {
    key     # a path
  , module
  }: let
    e = lib.evalModules {
      modules = [
        ( lib.libfloco.treeModuleFromGraphNode' args )
        module
      ];
    };
    childDeferred = p: {
      config.parent = e.config.node;
      config.tree   = e.config.tree;
      config.node   = ( removeAttrs e.config.tree.${p} [
        "scope" "children" "requires"
      ] ) // { pscope = lib.mkForce e.config.node.scope; };
    };
    mkChild = _: { path, ... }: {
      key    = path;
      module = childDeferred path;
    };
  in lib.mapAttrsToList mkChild e.config.node.children;

  # Collects `treeModuleFromGraphNode' recursively and evaluates to emit a
  # `tree' for a given `keylike' which is treated as the "root" node.
  treeForRoot = {
    graphNodeModules ? [graphNodeDeferred]
  , getChildReqs     ? null
  , pdefs
  } @ args: keylike: let
    base = {
      config.node = let
        key = if builtins.isString keylike then keylike else keylike.key or (
          keylike.ident + "/" + keylike.version
        );
      in {
        inherit key;
        ident   = keylike.ident or ( dirOf key );
        version = keylike.version or ( baseNameOf key );
        isRoot  = true;
        path    = "";
        pscope  = {};
      };
      config.parent = null;
      config.tree   = {};
    };
    moduleClosure = builtins.genericClosure {
      startSet = [{ key = ""; module = base; }];
      operator = treeModuleClosureOp args;
    };
    rough = let
      kids = map ( e: { inherit (e.module.config) tree; } ) moduleClosure;
    in lib.evalModules {
      modules = kids ++ [
        ( lib.libfloco.treeModuleFromGraphNode' args )
        base
      ];
    };
  in rough.extendModules {
    modules = let
      getRefsModule = path: node: { config.tree = collectRefsFromNode node; };
    in lib.mapAttrsToList getRefsModule rough.config.tree;
  };


# ---------------------------------------------------------------------------- #

  # `depInfoEntry' style properties indicating the conditions requires for a
  # node to be installed.
  # These relate closely to `treeInfo' properties, but are subtly different
  # in the meaning of `dev' - in this case we use the `depInfoEntry' treatment
  # of this field.
  treePropsDeferred = let
    dio = lib.libfloco.depInfoBaseEntryDeferred.options;
  in {
    options = {
      optional = lib.mkOption {
        inherit (dio.optional) description;
        type = lib.libfloco.boolAll;
      };
      runtime = lib.mkOption {
        inherit (dio.runtime) description;
        type = lib.libfloco.boolAny;
      };
      dev = lib.mkOption {
        inherit (dio.dev) description;
        type = lib.libfloco.boolAny;
      };
    };
  };

  treeProps = nt.submodule lib.libfloco.treePropsDeferred;

  mkTreePropsOption = lib.mkOption {
    description = lib.mdDoc ''
      Properties of a node indicating "why" a node is included in the graph,
      whether it is optional, which "stages"/modes may need it, etc.

      This record accepts arbitrary `bool` values for use by extensions, and
      aligns with the properties found in a `treeInfo` entry.
    '';
    type = lib.libfloco.treeProps;
  };


# ---------------------------------------------------------------------------- #

  # Functor/Interface used to build `treeInfo' records.

  treeInfoBuilderInterfaceDeferred = {
    options = {

      graphNodeModules = lib.mkOption {
        description = lib.mdDoc ''
          Modules used to form `graphNode` records.

          While the default list is sufficient for most use cases, this is
          exposed to allow users to implement extensions.
        '';
        type    = nt.listOf nt.deferredModule;
        default = [lib.libfloco.graphNodeDeferred];
      };

      getChildReqs = lib.mkOption {
        description = lib.mdDoc ''
          Function taking a `graphNode` as an argument, returning its `children`
          and `requires` collections ( `scope` submodules ).
        '';
        type = nt.functionTo ( nt.submodule {
          options.children = lib.libfloco.mkScopeOption;
          options.requires = lib.libfloco.mkScopeOption;
        } );
        default = lib.libfloco.getChildReqsBasic;
      };

      root = lib.mkOption {
        type = nt.submodule {
          options.keylike = lib.libfloco.mkKeylikeOption;
          options.pdef    = lib.mkOption { type = nt.lazyAttrsOf nt.raw; };
        };
      };

      pdefClosure = lib.mkOption {
        type = nt.lazyAttrsOf ( nt.lazyAttrsOf nt.raw );
      };

      tree = lib.mkOption {
        type = nt.lazyAttrsOf ( nt.submodule graphNodeDeferred );
      };

      propClosures = lib.mkOption {
        description = lib.mdDoc ''
          Lists representing closures of `tree` filtered by `props`.

          This is used as a base for `propTree` values and is required to avoid
          infinite recursion when cycles exist in references between tree nodes.
          It is otherwise impossible to assign properties in most "hoisted"
          style strategies.
        '';
        type = nt.submodule {
          options = {
            dev     = lib.mkOption { type = nt.listOf lib.libfloco.treePath; };
            runtime = lib.mkOption { type = nt.listOf lib.libfloco.treePath; };
            nopt    = lib.mkOption {
              description = lib.mdDoc ''
                List of `tree` paths that are reachable when all `optional`
                dependencies are ignored.

                This lists indicates nothing about `dev` and `runtime` props.
              '';
              type = nt.listOf lib.libfloco.treePath;
            };
          };
        };
      };

      propTree = lib.mkOption {
        type = nt.lazyAttrsOf lib.libfloco.treeProps;
      };

      treeInfo = lib.mkOption {
        type = nt.lazyAttrsOf nt.raw;
      };

    };
  };  # End `treeInfoBuilderInterfaceDeferred'


  # Implements a sane default for `treeInfoBuilderInterfaceDeferred'.
  treeInfoBuilderImplementationDeferred = {
    config
  , options
  , pdefs
  , keylike
  , ...
  }: {
    config.pdefClosure = lib.libfloco.pdefClosureWith {
      addRoot     = true;
      outputStyle = "ivAttrs";
    } { inherit pdefs; } keylike;

    config.root = {
      inherit keylike;
      pdef = lib.getPdef { inherit pdefs; } config.root.keylike;
    };

    config.tree = ( lib.libfloco.treeForRoot {
      inherit (config) graphNodeModules getChildReqs;
      inherit pdefs;
    } config.root.keylike ).config.tree;

    config.propClosures = {
      dev     = builtins.attrNames ( removeAttrs config.tree [""] );
      runtime = lib.libfloco.runTreeClosure {
        rootPred    = de: de.runtime;
        childPred   = de: de.runtime;
        addRoot     = false;
        outputStyle = "paths";
        audit       = true;
        inherit (config) tree;
      };
      nopt = lib.libfloco.runTreeClosure {
        rootPred    = de: ! de.optional;
        childPred   = de: de.runtime && ( ! de.optional );
        addRoot     = false;
        outputStyle = "paths";
        audit       = true;
        inherit (config) tree;
      };
    };

    config.propTree = let
      markPaths = paths:
        builtins.listToAttrs (
          map ( name: { inherit name; value = null; } ) paths
        );
      dtree   = markPaths config.propClosures.dev;
      rtree   = markPaths config.propClosures.runtime;
      otree   = markPaths config.propClosures.nopt;
      mkProps = path: _: {
        dev      = dtree ? ${path};
        runtime  = rtree ? ${path};
        optional = ! ( otree ? ${path} );
      };
      children = builtins.mapAttrs mkProps ( removeAttrs config.tree [""] );
      root."" = { dev = true; runtime = true; optional = false; };
    in root // children;

    config.treeInfo = let
      toTI = path: { dev, runtime, optional }: {
        inherit (config.tree.${path}) key;
        link = false;
        dev  = dev && ( ! runtime );
        inherit optional;
      };
    in builtins.mapAttrs toTI ( removeAttrs config.propTree [""] );
  };


  mkTreeInfoBuilder = {
    graphNodeModules ? null
  , getChildReqs     ? null
  , pdefs
  , keylike
  } @ args: let
    type = nt.submodule [
      treeInfoBuilderInterfaceDeferred
      treeInfoBuilderImplementationDeferred
    ];
  in lib.libfloco.runType type {
    config = ( removeAttrs args ["pdefs" "keylike"] ) // {
      _module.args = { inherit pdefs keylike; };
    };
  };


# ---------------------------------------------------------------------------- #

  mkTreeInfoWith = {
    graphNodeModules ? null
  , getChildReqs     ? null
  , config           ? {
      floco.pdefs = removeAttrs args ["graphNodeModules" "getChildReqs"];
    }
  , floco ? config.floco
  , pdefs ? floco.pdefs
  , ...
  } @ args: nodelike: let
    builder = lib.libfloco.mkTreeInfoBuilder {
      inherit pdefs;
      keylike = if builtins.isString nodelike then nodelike else
                if nodelike ? key then { inherit (nodelike) key; } else
                { inherit (nodelike) ident version; };
    };
  in builder.treeInfo;


# ---------------------------------------------------------------------------- #

  simplifyTree = x: let
    simplifyNode = path: node:
      ( removeAttrs node ["pscope" "ident" "version" "path"] ) // {
        children = builtins.mapAttrs ( _: c: c.pin ) node.children;
        depInfo  = let
          sy = d: removeAttrs d ["descriptor"];
        in builtins.mapAttrs ( _: sy ) node.depInfo;
      };
  in builtins.mapAttrs simplifyNode ( x.config.tree or x.tree or x );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  inherit
    treePath
    mkTreePathOption
    scopeEnt
    scope
    mkScopeOption
  ;


# ---------------------------------------------------------------------------- #

  inherit
    graphNodeInterfaceDeferred
    graphNodeDeferred
    graphNode
    treeModuleFromGraphNode'
    mkGraphNodeOption
    treeModuleClosureOp
    treeForRoot
    simplifyTree
  ;


# ---------------------------------------------------------------------------- #

  inherit
    referrerDeferred
    referrer
    mkReferrersOption
  ;


# ---------------------------------------------------------------------------- #

  inherit
    treePropsDeferred
    treeProps
    mkTreePropsOption
  ;


# ---------------------------------------------------------------------------- #

  inherit
    treeInfoBuilderInterfaceDeferred
    treeInfoBuilderImplementationDeferred
    mkTreeInfoBuilder
    mkTreeInfoWith
  ;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
