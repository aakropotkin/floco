# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  scopeEnt = nt.submodule {
    options = {
      pin  = lib.libfloco.mkPinOption;
      path = lib.mkOption {
        description = lib.mdDoc ''
          Filesystem path where a scoped module will be installed.

          This is useful for marking consumers as `referrers` of a module.
        '';
        type = nt.either nt.str lib.libfloco.relpath;
      };
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

  pdefFromGraphNode = node: removeAttrs node [
    "path" "isRoot" "pscope" "children" "requires" "scope" "referrers" "props"
  ];

  graphNodeCoreFromPdef = pdef: removeAttrs pdef [
    "_export" "metaFiles" "fsInfo" "fetchInfo" "sourceInfo" "binInfo"
    "deserialized" "fetcher"
  ];


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
      depth     = lib.mkOption { type = nt.ints.unsigned; default = 0; };
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
      depth   = lib.mkDerivedConfig options.path lib.libfloco.nmDepth;
      isRoot  = lib.mkOptionDefault (
        ! ( lib.hasInfix "node_modules/" config.path )
      );
      requires = lib.mkDefault cr.requires;
      children = lib.mkDefault cr.children;
      scope    = lib.mkDefault (
        cr.scope or ( config.pscope // config.children )
      );
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
  collectRefsFromNode = {
    key
  , path
  , requires
  , children
  , ...
  }: let
    proc = ident: scopeEnt: {
      name            = scopeEnt.path;
      value.referrers = [{ inherit key path; }];
    };
    rs  = lib.mapAttrs' proc ( lib.attrsets.unionOfDisjoint requires children );
    ov  = builtins.intersectAttrs requires children;
    msg =
      "Found overlapping attrs at `${path}' for `${key}' requires/children: "
      + ( builtins.concatStringsSep " " ( builtins.attrNames ov ) );
  in if ov == {} then rs else throw msg;


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

  treeModuleForRoot = {
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

  #treeFromGraphNode = {
  #  graphNodeModules ? [graphNodeDeferred]
  #, getChildReqs     ? null
  #, pdefs            ? floco.pdefs
  #, floco            ? config.floco
  #, config           ? {
  #    floco.pdefs = removeAttrs args ["graphNodeModules" "getChildReqs"];
  #  }
  #, ...
  #} @ args: nodelike: ( lib.evalModules {
  #  modules = [( lib.libfloco.treeModuleFromGraphNode {
  #    inherit graphNodeModules getChildReqs pdefs;
  #  } nodelike )];
  #} ).config.tree;


# ---------------------------------------------------------------------------- #

  treePropsDeferred = {
    freeformType = nt.lazyAttrsOf nt.bool;
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
  };

  treeProps = nt.submodule lib.libfloco.treePropsDeferred;

  mkTreePropsOption = lib.mkOption {
    description = lib.mdDoc ''
      Properties of a node indicating "why" a node is included in the graph,
      whether it is optional, which "stages"/modes may need it, etc.

      This record accepts arbitrary `bool` values for use by extensions, and
      aligns with the properties found in a `treeInfo` entry.
    '';
    type    = lib.libfloco.treeProps;
    default = {};
  };

  propsFromReferrer = ptree: ident: refPath: let
    gnode   = ptree.${refPath};
    forRoot = { inherit (gnode.depInfo.${ident}) optional runtime dev; };
    forSub  = gnode.props // {
      optional = gnode.props.optional ||
                 ( gnode.depInfo.${ident} or gnode.peerInfo.${ident} ).optional;
    };
  in if gnode.isRoot then forRoot else forSub;

  propsFromTree = ptree: path: let
    gnode = ptree.${path};
  in if gnode.isRoot then {
    config = { optional = false; runtime = true; dev = true; };
  } else {
    imports = map ( r: propsFromReferrer ptree gnode.ident r.path )
                  gnode.referrers;
  };

  propNodeDeferred = { options, config, ... }: {
    freeformType = nt.attrsOf nt.anything;
    options      = {
      props = lib.libfloco.mkTreePropsOption;
      inherit (( graphNodeDeferred {
        inherit options config; getChildReqs = null;
      } ).options) ident depInfo peerInfo isRoot referrers;
    };
  };

  propTreeDeferred = { config, tree, ... }: {
    options.ptree = lib.mkOption {
      type    = nt.lazyAttrsOf ( nt.submodule propNodeDeferred );
      default = {};
    };
    config = {
      ptree = let
        proc = path: gnode: gnode // {
          props = _: propsFromTree config.ptree path;
        };
      in builtins.mapAttrs proc tree;
    };
  };


# ---------------------------------------------------------------------------- #

  #mkTreeInfoWith = {
  #  graphNodeModules ? null
  #, getChildReqs     ? null
  #, pdefs            ? null
  #, floco            ? null
  #, config           ? null
  #, ...
  #} @ args: nodelike: let
  #  inherit (( lib.evalModules {
  #    modules = [
  #      lib.libfloco.propTreeDeferred
  #      {
  #        config._module.args.tree =
  #          lib.libfloco.treeFromGraphNode args nodelike;
  #      }
  #    ];
  #  } ).config) ptree;
  #  toTI  = { key, props, ... }: {
  #    inherit key;
  #    link = false;
  #    dev  = props.dev && ( ! props.runtime );
  #    # For debugging:
  #    ##_props = props;
  #  } // ( removeAttrs props ["runtime" "dev"] );
  #  base = builtins.mapAttrs ( _: toTI ) ptree;
  #in removeAttrs base [""];


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  inherit
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
    treeModuleForRoot
    treeModuleClosureOp
  ;


# ---------------------------------------------------------------------------- #

  inherit
    treePath
    mkTreePathOption
    referrerDeferred
    referrer
    mkReferrersOption
  ;


# ---------------------------------------------------------------------------- #

  inherit
    treePropsDeferred
    treeProps
    mkTreePropsOption
    propsFromReferrer
    propsFromTree
    propNodeDeferred
    propTreeDeferred
    #mkTreeInfoWith
  ;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
