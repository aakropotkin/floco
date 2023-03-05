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
        pre = if path == "" then "node_modules/" else path + "/";
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

  getChildReqsBasic = {
    ident
  , version
  , path
  , depInfo
  , peerInfo
  , isRoot
  , needs  ? if isRoot then depInfo else lib.libfloco.getRuntimeDeps {} depInfo
  , pscope
  , ...
  } @ node: let
    keep = di: de: ( pscope.${di}.pin or null ) == de.pin;
    part = lib.partitionAttrs keep needs;
    bund = lib.libfloco.getDepsWith ( de: de.bundled or false ) depInfo;
  in {
    requires = builtins.intersectAttrs part.right pscope;
    children = builtins.mapAttrs ( _: d: d.pin ) ( bund // part.wrong );
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

      props = lib.mkOption {
        type = nt.submodule {
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
        default = {};
      };

    };

    config = let
      cr = getChildReqs {
        inherit (config) ident version path depInfo peerInfo isRoot pscope;
      };
    in {
      _module.args.getChildReqs = lib.mkOptionDefault getChildReqsBasic;

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
    };

  };

  graphNode = nt.submodule graphNodeDeferred;


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
    in ( lib.toList graphNodeModules ) ++ gcrMod ++ [
      { options.reaped = lib.mkOption { type = nt.bool; default = false; }; }
    ];

    pdef = if builtins.isString nodelike then lib.getPdef pdefs nodelike else
           if graphNode.check nodelike then pdefFromGraphNode nodelike else
           if ! ( nodelike ? depInfo ) then lib.getPdef pdefs nodelike else
           removeAttrs nodelike ["isRoot" "path"];

    isRoot = nodelike.isRoot or ( ! ( graphNode.check nodelike ) );

    node = if graphNode.check nodelike then nodelike else ( lib.evalModules {
      modules = [
        {
          options.gnode = lib.mkOption { type = nt.submodule gnMods; };
          config.gnode  = let
            path' = if ! isRoot then {} else { path = nodelike.path or ""; };
          in ( graphNodeCoreFromPdef pdef ) // path' // {
            inherit isRoot; reaped = true;
          };
        }
      ];
    } ).config.gnode;

    pathFor = let
      pre = if node.path == "" then "node_modules/" else
            node.path + "/node_modules/";
    in ident: pre + ident;

    getNode = ident: vlike: extraCfg: {
      inherit ident;
      version   = vlike.pin or vlike.version or vlike;
      path      = pathFor ident;
      referrers = [{ inherit (node) key path; }];
      props     = if isRoot then {
        inherit (node.depInfo.${ident}) optional runtime dev;
      } else {
        optional = node.props.optional || node.depInfo.${ident}.optional;
        inherit (node.props) runtime dev;
      };
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
    getChildReqsBasic
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


  mkTreeInfoWith = {
    graphNodeModules ? null
  , getChildReqs     ? null
  , pdefs            ? null
  , floco            ? null
  , config           ? null
  , ...
  } @ args: nodelike: let
    graph = lib.libfloco.treeFromGraphNode args nodelike;
    base  = builtins.mapAttrs ( _: v: v.props // { inherit (v) key; } ) graph;
  in removeAttrs base [""];


}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
