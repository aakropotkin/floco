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
      path = lib.mkOption { type = nt.either nt.str lib.libfloco.relpath; };
    };
  };

  scope = nt.lazyAttrsOf scopeEnt;


# ---------------------------------------------------------------------------- #

  # Coerce a `depInfoEnt' colleciton to a `pin' collection.
  pinsFromDepInfo = nt.lazyAttrsOf (
    nt.coercedTo ( nt.lazyAttrsOf nt.anything ) ( x: x.pin )
                 lib.libfloco.version
  );


# ---------------------------------------------------------------------------- #

  mkScopeFromDepInfo = path: depInfo: let
    proc = ident: de: {
      path = let
        pre = if path == "" then "node_modules/" else path + "/node_modules/";
      in de.path or ( pre + ident );
      pin  = de.pin or de;
    };
  in builtins.mapAttrs proc depInfo;

  scopeFromDepInfo = path: let
    fromT = ( nt.lazyAttrsOf nt.anything ) // {
      check = x: ( builtins.isAttrs x ) && (
        ! ( builtins.all scopeEnt.check ( builtins.attrValues x ) )
      );
    };
  in nt.coercedTo fromT ( mkScopeFromDepInfo path ) scope;


# ---------------------------------------------------------------------------- #

  pdefFromGraphNode = node: removeAttrs node [
    "path" "isRoot" "pscope" "children" "requires" "scope" "referrers" "props"
  ];

  graphNodeCoreFromPdef = pdef: removeAttrs pdef [
    "_export" "metaFiles" "fsInfo" "fetchInfo" "sourceInfo" "binInfo"
    "deserialized" "fetcher"
  ];


# ---------------------------------------------------------------------------- #

  graphNodeDeferred = {
    config
  , options
  , getChildReqs
  , ...
  }: {
    freeformType = nt.attrsOf nt.anything;
    options      = {
      ident   = lib.libfloco.mkIdentOption;
      version = lib.libfloco.mkVersionOption;
      key     = lib.libfloco.mkKeyOption;

      depInfo = lib.libfloco.mkDepInfoBaseOption;

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

    };  # End `options'

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
      isRoot  = lib.mkOptionDefault (
        ! ( lib.hasInfix "node_modules/" config.path )
      );
      pscope = let
        dft = if config.isRoot then {} else {
          ${config.ident} = { inherit (config) path; pin = config.version; };
        };
      in lib.mkDefault dft;
      requires = builtins.mapAttrs ( _: lib.mkDefault ) cr.requires;
      children = builtins.mapAttrs ( _: lib.mkDefault ) cr.children;
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

  treeModuleFromGraphNode = {
    graphNodeModules ? [graphNodeDeferred]
  , getChildReqs     ? null
  , pdefs
  }: nodelike: let

    gnMods = let
      gcrMod = if getChildReqs == null then [] else [
        { config._module.args.getChildReqs = lib.mkDefault getChildReqs; }
      ];
    in ( lib.toList graphNodeModules ) ++ gcrMod;

    pdef = if builtins.isString nodelike then lib.getPdef pdefs nodelike else
           if graphNode.check nodelike then pdefFromGraphNode nodelike else
           if ! ( nodelike ? depInfo ) then lib.getPdef pdefs nodelike else
           removeAttrs nodelike ["isRoot" "path"];

    isRoot = nodelike.isRoot or ( ! ( graphNode.check nodelike ) );

    node = let
      fromPdef = ( lib.evalModules {
        modules = [
          {
            options.gnode = lib.mkOption { type = nt.submodule gnMods; };
            config.gnode  = let
              path' = if ! isRoot then {} else { path = nodelike.path or ""; };
            in ( graphNodeCoreFromPdef pdef ) // path' // { inherit isRoot; };
          }
        ];
      } ).config.gnode;
    in if graphNode.check nodelike then nodelike else fromPdef;

    pathFor = let
      pre = if node.path == "" then "node_modules/" else
            node.path + "/node_modules/";
    in ident: pre + ident;

    getNode = ident: vlike: extraCfg: {
      inherit ident;
      version   = vlike.pin or vlike.version or vlike;
      path      = pathFor ident;
      referrers =
        if ! ( node.peerInfo // node.depInfo ) ? ${ident} then [] else
        [{ inherit (node) key path; }];
    } // extraCfg;

    reqModList = let
      forDep = ident: vlike: extraCfg: let
        dnode = getNode ident vlike extraCfg;
      in { name = dnode.path; value = dnode; };
    in lib.mapAttrsToList ( i: v: forDep i v {
      path = node.pscope.${i}.path;
    } ) node.requires;

    childModList = lib.mapAttrsToList ( i: v: let
      cnode = ( lib.evalModules {
        modules = [
          {
            options.gnode = lib.mkOption { type = nt.submodule gnMods; };
            config.gnode  = let
              dpdef = lib.libfloco.getPdef pdefs {
                ident = i; version = v.pin or v.version or v;
              };
              cmod = getNode i v { pscope = node.scope; isRoot = false; };
            in ( graphNodeCoreFromPdef dpdef ) // cmod;
          }
        ];
      } ).config.gnode;
      sub = treeModuleFromGraphNode {
        inherit graphNodeModules getChildReqs pdefs;
      } cnode;
    in removeAttrs sub ["options"] ) node.children;

  in {
    options.tree = lib.mkOption {
      type    = nt.lazyAttrsOf ( nt.submodule gnMods );
      default = {};
    };
    imports =
      [{ config.tree = builtins.listToAttrs reqModList; }] ++ childModList;
    config.tree.${node.path} = node;
  };


# ---------------------------------------------------------------------------- #

  treeFromGraphNode = {
    graphNodeModules ? [graphNodeDeferred]
  , getChildReqs     ? null
  , pdefs            ? floco.pdefs
  , floco            ? config.floco
  , config           ? {
      floco.pdefs = removeAttrs args ["graphNodeModules" "getChildReqs"];
    }
  , ...
  } @ args: nodelike: ( lib.evalModules {
    modules = [( lib.libfloco.treeModuleFromGraphNode {
      inherit graphNodeModules getChildReqs pdefs;
    } nodelike )];
  } ).config.tree;


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

  mkTreeInfoWith = {
    graphNodeModules ? null
  , getChildReqs     ? null
  , pdefs            ? null
  , floco            ? null
  , config           ? null
  , ...
  } @ args: nodelike: let
    inherit (( lib.evalModules {
      modules = [
        lib.libfloco.propTreeDeferred
        {
          config._module.args.tree =
            lib.libfloco.treeFromGraphNode args nodelike;
        }
      ];
    } ).config) ptree;
    toTI  = { key, props, ... }: {
      inherit key;
      link = false;
      dev  = props.dev && ( ! props.runtime );
      # For debugging:
      ##_props = props;
    } // ( removeAttrs props ["runtime" "dev"] );
    base = builtins.mapAttrs ( _: toTI ) ptree;
  in removeAttrs base [""];


# ---------------------------------------------------------------------------- #

in {

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
    mkGraphNodeOption
    treeFromGraphNode
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
    mkTreeInfoWith
  ;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
