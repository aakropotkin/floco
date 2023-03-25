# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  # Build a `depInfoEntry' predicate where fields in `args' are checked.
  # `boolean' fields in `args' must match the fields in the `depInfoEntry',
  # while `null' fields in `args' are ignored ( skipped ).
  # Extraneous fields in `depInfoEntry' are ignored.
  mkDepInfoEntryPred = {
    runtime  ? null
  , dev      ? null
  , optional ? null
  , bundled  ? null
  } @ args: {
    mask = ( if runtime  == null then {} else { inherit runtime;  } ) //
           ( if dev      == null then {} else { inherit dev;      } ) //
           ( if optional == null then {} else { inherit optional; } ) //
           ( if bundled  == null then {} else { inherit bundled;  } );
    __functor = self: de:
      if self.mask == {} then true else
      self.mask == ( builtins.intersectAttrs self.mask de );
  };


  depInfoEntryPredAttrs = let
    fargs = { runtime = null; dev = null; optional = null; bundled = null; };
    base  = nt.attrsOf ( nt.nullOr nt.bool );
    pred  = x: ( builtins.intersectAttrs fargs x ) == x;
  in nt.addCheck base pred;

  depInfoEntryPredFunk = let
    base      = lib.libfloco.funkTo nt.bool;
    checkDry  = f: builtins.isBool ( f {
      ident    = "@floco/phony";
      runtime  = true;
      dev      = true;
      optional = true;
      bundled  = true;
    } );
    checkMask = f:
      ( builtins.isFunction f ) ||
      ( ! ( f ? mask ) ) ||
      ( depInfoEntryPredAttrs.check f.mask );
  in nt.addCheck base ( f: ( checkMask f ) && ( checkDry f ) );

  # Typed form of `mkDepInfoEntryPred' making it usable in typed modules.
  depInfoEntryPred = let
    base = nt.coercedTo depInfoEntryPredAttrs
                        mkDepInfoEntryPred
                        depInfoEntryPredFunk;
  in base // {
    name  = "depInfoEntryPred";
    merge = loc: defs: let
      fixFunctions = d: if ! builtins.isFunction d.value then d else d // {
        value.__functor = _: d.value;
      };
    in base.merge loc ( map fixFunctions defs );
  };


  # Declares a `depInfoEntryPred' option for use in a module.
  mkDepInfoEntryPredOption = lib.mkOption {
    description = lib.mdDoc ''
      A predicate used to filter `depInfo` records' entries.

      May be set using a predicate which accepts a `depInfoEntry` argument, or
      an attrset of `null|bool` args with the fields
      `{ runtime, dev, optional, bundled }` indicating that `null` fields should
      be ignored, and `bool` fields must match in the entry.
    '';
    type            = depInfoEntryPred;
    default.runtime = true;
    example         = lib.literalExpression ''
      {
        # Assigment as a function
        rootPred  = de: de.runtime || de.dev;

        # Assigment with "matched fields".
        # `bundled` and `optional` may be `true` or `false`, since the matcher
        # marked them as `null` ( the default ).
        childPred = { runtime = true; dev = false; bundled = null; };
      }
    '';
  };


# ---------------------------------------------------------------------------- #

  # Common dependency getters.
  # These are convenience wrappers over the `mkDepInfoEntryPred' interface
  # used to filter `depInfo' collections.

  # getDepsWith :: predlike -> (pdef|depInfo) -> depInfo
  # ----------------------------------------------------
  getDepsWith = predlike: let
    pred = if lib.isFunction predlike then predlike else
           lib.libfloco.mkDepInfoEntryPred predlike;
  in x: lib.filterAttrs ( ident: entry: pred ( { inherit ident; } // entry ) )
                        ( x.depInfo or x );

  # getRuntimeDeps :: { optional?, bundled? } -> (pdef|depInfo) -> depInfo
  # ----------------------------------------------------------------------
  # Pull any `runtime' dependencies.
  # First argument can be used to indicate handling of `optional' and `bundled'.
  getRuntimeDeps = { optional ? null, bundled ? null } @ mask:
    lib.libfloco.getDepsWith ( mask // { runtime = true; } );

  # getDevDeps :: { optional?, bundled? } -> (pdef|depInfo) -> depInfo
  # ------------------------------------------------------------------
  # Pull any `dev' dependencies.
  # First argument can be used to indicate handling of `optional' and `bundled'.
  getDevDeps = { optional ? null, bundled ? null } @ mask:
    getDepsWith ( mask // { dev = true; } );


# ---------------------------------------------------------------------------- #

  # Typed `functor' used to collect dependency closures.
  #
  # This interface can be included in modules or used standalone with the
  # convenience wrappers `mkPdefClosureFunctor` or`pdefClosure[With]'.
  #
  # The default implementation `pdefClosureFunctorImplementationDeferred'
  # is used in all convenience wrappers, but it is possible to override or
  # extend this implementation using `pdefClosure[Functor]With'.

  pdefClosureFunctorInterfaceDeferred = {
    options = {

      addRoot = lib.mkOption {
        description = lib.mdDoc ''
          Whether the `root` entry should always be included in the closure.

          If this is disabled, the `root` entry will only appear if it a member
          of a dependency cycle with another element.
        '';
        type    = nt.bool;
        default = true;
        example = false;
      };

      rootPred = lib.libfloco.mkDepInfoEntryPredOption // {
        default = {};
      };

      childPred = lib.libfloco.mkDepInfoEntryPredOption // {
        default.runtime = true;
      };

      getPdef = lib.mkOption {
        description = lib.mdDoc ''
          Function that looks up a `pdef` ( or equivelant ) from a `keylike`.

          This takes a two arguments:
          1. the `payload` value stashed in the functor, used for misc. storage.
          2. a `keylike` ( string ) or an attrset containing at least
             `{ key }`, or `{ ident, version }`.
        '';
        type    = nt.functionTo nt.raw;
        example = lib.literalExpression ''
          { lib, pdefs, ... }: {
            config = {
              payload = { inherit pdefs; }
              inherit (lib.libfloco) getPdef;
            };
          }
        '';
        default = lib.libfloco.getPdef;
      };

      mkEntry = lib.mkOption {
        description = lib.mdDoc ''
          Post processing function applied to each `pdef`.
        '';
        type = nt.functionTo nt.raw;
        example = lib.literalExpression ''
          {
            mkEntry = builtins.intersectAttrs {
              key     = null;
              ident   = null; version  = null;
              depInfo = null; peerInfo = null;
            };
          }
        '';
        default = pdef: pdef._export or ( removeAttrs pdef [
          "metaFiles" "deserialized" "fsInfo" "binInfo"
          "fetcher" "fetchInfo" "sourceInfo"
        ] );
      };

      outputStyle = lib.mkOption {
        description = lib.mdDoc ''
          The desired collection/container to be returned.
          Elements are the result of `mkEntry`.
          - list:    a flat list of elements in BFS order.
          - idGroup: lists of elements in BFS order grouped by `ident`.
          - ivAttrs: `{ <IDENT> = { <VERSION> = { ... }; ...; }; ...; }`.
        '';
        type    = nt.enum ["list" "idGroup" "ivAttrs"];
        default = "list";
        example = "ivAttrs";
      };

      payload = lib.mkOption {
        description = lib.mdDoc ''
          Misc. attributes for use by `getPdef` and `__functor`.
          When using the default `getPdef` function you must stash the full
          `pdefs` ( in `ivAttrs` style ) as a member.
        '';
        type = nt.submodule {
          freeformType  = nt.lazyAttrsOf nt.raw;
          options.pdefs = lib.mkOption {
            description = lib.mdDoc ''
              Full pool of `pdefs` used for lookups when collecting closures.
              This must be in `ivAttrs` style ( nested attrsets ).
            '';
            type     = nt.lazyAttrsOf ( nt.lazyAttrsOf nt.raw );
            readOnly = true;
          };
        };
      };

      __functor = lib.mkOption {
        description = lib.mdDoc ''
          Given a `keylike` argument, produce a `pdefClosure` using the settings
          and and `payload` held by other `config` members.
        '';
        type = nt.functionTo ( nt.functionTo nt.raw );
        #readOnly = true;
      };

      # Helper routines exposed for debugging and repurposing by extensions.
      _private = lib.mkOption {
        internal = true;
        visible  = false;
        type     = nt.submodule {
          freeformType = nt.lazyAttrsOf nt.raw;
          options = {
            # __mkStartSet :: self -> pdef -> [pdef]
            __mkStartSet = lib.mkOption {
              type     = nt.functionTo ( nt.functionTo ( nt.listOf nt.raw ) );
              readOnly = true;
            };
            # __operator :: self -> pdef -> [pdef]
            __operator = lib.mkOption {
              type     = nt.functionTo ( nt.functionTo ( nt.listOf nt.raw ) );
              readOnly = true;
            };
            # _handleStyle :: style -> [entries] -> any
            _handleStyle = lib.mkOption {
              type     = nt.functionTo ( nt.functionTo nt.raw );
              readOnly = true;
            };
          };
        };
      };  # End `options._private'

    };  # End `options'
  };  # End `pdefClosureFunctorInterfaceDeferred'


  # Default implementation of `pdefClosureFunctorInterfaceDeferred'.
  pdefClosureFunctorImplementationDeferred = {
    lib
  , config
  , options
  , pdefs
  , ...
  }: {
    config = {
      _module.args.pdefs = lib.mkOptionDefault {};
      payload            = { inherit pdefs; };

      _private = let
        getDep = self: ident: { pin, ... }:
          self.getPdef self.payload { inherit ident; version = pin; };
      in lib.mkOptionDefault {
        __mkStartSet = self: pdef: let
          depEnts = lib.libfloco.getDepsWith self.rootPred pdef;
        in builtins.attrValues ( builtins.mapAttrs ( getDep self ) depEnts );
        __operator = self: pdef: let
          depEnts = lib.libfloco.getDepsWith self.childPred pdef;
        in builtins.attrValues ( builtins.mapAttrs ( getDep self ) depEnts );
        _handleStyle = style: ents:
          if style == "list"    then ents else
          if style == "ivAttrs" then lib.libfloco.pdefsFromList ents else
          if style == "idGroup" then builtins.groupBy ( v: v.ident ) ents else
          throw ( "lib.libfloco.pdefClosureFunctor: " +
                  "Unrecognized `outputStyle': \"${style}\"." );
      };

      # The acutal function "driver".
      # This is intentionally split into two separate `let' blocks so the
      # evaluator can optimize processing partially applied functions.
      # NOTE: for the evaluator to actually do this you need to use `seq', but
      # for a "hot" callpath this can be a real advantage.
      __functor = lib.mkOptionDefault ( self: let
        mkStartSet = config._private.__mkStartSet self;
        operator   = config._private.__operator   self;
        # handleStyle :: [entries] -> <STYLE>
        handleStyle = config._private._handleStyle self.outputStyle;
      in keylike: let
        root    = self.getPdef self.payload keylike;
        closure = builtins.genericClosure {
          inherit operator;
          startSet = mkStartSet root;
        };
        wroot = let
          hasRoot = builtins.any ( v: v.key == root.key ) closure;
        in if ( ! self.addRoot ) || hasRoot then closure else [root] ++ closure;
      in handleStyle ( map self.mkEntry wroot ) );
    } ;
  };

  # Declare a `pdefClosureFunctor' type with module extensions.
  #
  # Using the attrset `{ modules = [...]; implementation = <MODULE>; }' you
  # can completely replace the default implementation.
  # This may be useful if you want to modify the treatment args like `pdefs`.
  pdefClosureFunctorWith = extra: let
    extraModules =
      if ! ( builtins.isAttrs extra ) then lib.toList extra else
      if extra == {} then [] else
      lib.toList ( extra.modules or ( removeAttrs extra ["implementation"] ) );
  in nt.submodule ( [
    pdefClosureFunctorInterfaceDeferred
    ( extra.implementation or pdefClosureFunctorImplementationDeferred )
  ] ++ extraModules );


  # Declare a `pdefClosureFunctor' type without extensions.
  pdefClosureFunctor = lib.libfloco.pdefClosureFunctorWith {};


  # Wraps the module in a convenience function so we can do this:
  #   mkPdefClosureFunctor {} ( lib.evalModules { ... } ) "@foo/bar/4.2.0"
  #   mkPdefClosureFunctor { inherit (config.floco) pdefs; } "@foo/bar/4.2.0"
  mkPdefClosureFunctor = {
    modules     ? []
  , addRoot     ? args.config.addRoot     or null
  , rootPred    ? args.config.rootPred    or null
  , childPred   ? args.config.childPred   or null
  , getPdef     ? args.config.getPdef     or null
  , mkEntry     ? args.config.mkEntry     or null
  , outputStyle ? args.config.outputStyle or null
  , payload     ? args.config.payload     or {}
  , pdefs       ? args.config.payload.pdefs or args.config._module.pdefs or {}
  , config      ? ( removeAttrs args ["modules" "pdefs"] ) // {
      _module.args = ( args._module.args or {} ) // { inherit pdefs; };
      inherit payload;
    }
  , ...
  } @ args: let
    type = lib.libfloco.pdefClosureFunctorWith { inherit modules; };
    f    = removeAttrs ( lib.libfloco.runType type config ) ["_private"];
    curried = f // {
      __functor = self: {
        config ? { floco.pdefs = pa; }
      , floco  ? config.floco
      , pdefs  ? floco.pdefs
      , ...
      } @ pa: self // {
        payload = ( self.payload or {} ) // { inherit pdefs; };
        inherit (f) __functor;
      };
    };
    # If `pdefs' wasn't provided we can take the opportunity to eagerly eval
    # everything else in the functor for a slight evaluator optimization.
    # Evaluating when `pdefs' is given would be a huge performance hit, so be
    # careful in the future on any refactors.
  in if pdefs == {} then builtins.deepSeq curried curried else f;


# ---------------------------------------------------------------------------- #

  # pdefClosureWith :: config -> pdefs -> keylike -> [entries]
  # ----------------------------------------------------------
  # Plain function form of `pdefClosureFunctor'.
  # Accepts "non-module style" arguments for `config'.
  # Requires `pdefs' and `keylike' to be curried arguments.
  pdefClosureWith = {
    __functionArgs =
      removeAttrs ( lib.functionArgs lib.libfloco.mkPdefClosureFunctor ) [
        "modules" "config" "pdefs"
      ];
    __functor = self: {
      mkEntry ? builtins.intersectAttrs {
        key     = null; ident    = null; version = null;
        depInfo = null; peerInfo = null;
      }
    , ...
    } @ args: lib.libfloco.mkPdefClosureFunctor {
      config = { inherit mkEntry; } // ( removeAttrs args [
        "modules" "config" "pdefs"
      ] );
      pdefs = {};
    };
  };

  # pdefClosure :: pdefs -> keylike -> [entries]
  # --------------------------------------------
  # Given a collection of `pdefs' and a "keylike" identifier treated as the
  # "root" package, return the `dev' mode closure of dependencies.
  # Only `dev' dependencies of the "root" are included, all other modules only
  # collect their `runtime' deps.
  pdefClosure = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosureWith {} pdefs keylike;


# ---------------------------------------------------------------------------- #

  pdefClosureCachedFunctorImplementationDeferred = {
    lib
  , config
  , options
  , pdefs
  , cache
  , mkEntry
  , ...
  }: {

    # This caching style keys queries in exactly the same way as Nix's own
    # eval cache.
    # This leaves the door open to using a `nix' plugin to satisfy this same
    # interface at a later date using builtins.
    options.payload = lib.mkOption {
      type = nt.submodule {
        options.cache = lib.mkOption {
          description = lib.mdDoc ''
            Cached closures used to short circuit collection of subtrees.

            Maps `{ <KEY> = { <MASK> = [KEY...]; ...; }; ... }`.
            `MASK` is a serialized form of a `depEntryPred` such as:
              `{"runtime":true}`
            This means that both `rootPred` and `childPred` must be encoded
            using a `depInfoEntryPred` functor, otherwise no cache lookup
            will be performed and "normal" closure operators will run.
          '';
          type =
            nt.lazyAttrsOf ( nt.lazyAttrsOf ( nt.listOf lib.libfloco.key ) );
        };
      };
    };

    options.__cacheChild = lib.mkOption {
      description = lib.mdDoc ''
        Functor which pre-caches a child's closure, returning a modified `self`.

        Takes `self` as first argument and `keylike` as the second.
        If `childPred` is not serializable or if `keylike` is already cached
        this is a no-op.
      '';
      type = nt.functionTo ( nt.functionTo nt.raw );
    };

    config._module.args.cache = lib.mkOptionDefault {};
    config.payload.cache      = lib.mkDefault cache;

    # Extend the "base" definition provided by the user.
    config._module.args.mkEntry = lib.mkOptionDefault ( pdef:
      pdef._export or ( removeAttrs pdef [
        "metaFiles" "deserialized" "fsInfo" "binInfo"
        "fetcher" "fetchInfo" "sourceInfo"
      ] )
    );
    config.mkEntry = lib.mkDefault ( pdef:
      mkEntry ( removeAttrs pdef ["_fromCache"] )
    );

    config.rootPred  = lib.mkDefault {};
    config.childPred = lib.mkDefault { runtime = true; };

    config._private = let
      base = pdefClosureFunctorImplementationDeferred {
        inherit lib config options pdefs;
      };
      op = self: pred: pdef: let
        maskStr  = pred.ckey or ( builtins.toJSON pred.mask );
        isCached = ( builtins.isAttrs pred ) && ( pred ? mask ) &&
                   ( self.payload.cache ? ${pdef.key}.${maskStr} );
        getCached = key:
          ( self.getPdef self.payload key ) // { _fromCache = true; };
        fromCache  = map getCached self.payload.cache.${pdef.key}.${maskStr};
        getDep     = ident: { pin, ... }:
          self.getPdef self.payload { inherit ident; version = pin; };
        normal     = lib.libfloco.getDepsWith pred pdef;
        fromNormal = builtins.attrValues ( builtins.mapAttrs getDep normal );
      in if pdef._fromCache or false then [] else
         if isCached then fromCache else fromNormal;
    in {
      inherit (base.config._private.content or base.config._private)
        _handleStyle
      ;
      __mkStartSet = self: op self self.rootPred;
      __operator   = self: op self self.childPred;
    };

    config.__cacheChild = self: let
      cself = self // {
        addRoot     = false;
        rootPred    = self.childPred;
        outputStyle = "list";
        mkEntry     = pdef: pdef.key;
      };
      maskStr = self.childPred.ckey or ( builtins.toJSON self.childPred.mask );
      hasKey  = ( self.childPred ? mask ) || ( self.childPred ? ckey );
    in keylike: let
      kl       = lib.libfloco.runKeylike keylike;
      isCached = self.payload.cache ? ${kl.key}.${maskStr};
    in if ( ! hasKey ) || isCached then self else self // {
      payload = ( self.payload or {} ) // {
        cache = ( self.payload.cache or {} ) // {
          ${kl.key}.${maskStr} = cself kl;
        };
      };
    };

  };  # End `pdefClosureCachedFunctorImplementationDeferred'

  pdefClosureCachedFunctor =
    lib.libfloco.pdefClosureFunctorWith
      pdefClosureCachedFunctorImplementationDeferred;

  mkPdefClosureCachedFunctor = {
    __functionArgs = lib.functionArgs lib.libfloco.mkPdefClosureFunctor // {
      cache = true;
    };
    __functor = self: {
      modules ? []
    , cache   ? {}
    , pdefs   ? args.config.payload.pdefs or args.config._module.pdefs or {}
    , payload ? args.config.payload or { inherit cache; }
    , config  ? ( removeAttrs args ["modules" "pdefs" "cache"] ) // {
        _module.args = ( args._module.args or {} ) // { inherit pdefs; };
        inherit payload;
      }
    , ...
    } @ args: let
      type = lib.libfloco.pdefClosureFunctorWith {
        modules = [pdefClosureCachedFunctorImplementationDeferred] ++
                  ( lib.toList modules );
      };
      f    = removeAttrs ( lib.libfloco.runType type config ) ["_private"];
      curried = f // {
        __functor = self: {
          config ? { floco.pdefs = pa; }
        , floco  ? config.floco
        , pdefs  ? floco.pdefs
        , ...
        } @ pa: self // {
          payload = ( self.payload or {} ) // { inherit pdefs; };
          inherit (f) __functor;
        };
      };
      # If `pdefs' wasn't provided we can take the opportunity to eagerly eval
      # everything else in the functor for a slight evaluator optimization.
      # Evaluating when `pdefs' is given would be a huge performance hit, so be
      # careful in the future on any refactors.
    in if pdefs == {} then builtins.deepSeq curried curried else f;
  };


# ---------------------------------------------------------------------------- #

  # Check that `peerDependencies' declared by direct dependencies are listed as
  # direct dependencies.
  # Do not audit versions/semver ranges, just check to see if they are present.`
  # Requires pins for all dependencies.
  checkPeersPresent' = pdefs: {
    key     ? ident + "/" + version
  , ident   ? dirOf key
  , version ? baseNameOf key
  }: let
    pdef  = lib.libfloco.getPdef pdefs { inherit ident version; };
    rtDIs = getRuntimeDeps {} pdef;
    deps = let
      get = ident: { pin, runtime ? false, optional ? false, ... }:
        ( lib.libfloco.getPdef pdefs { inherit ident; version = pin; } ) // {
          inherit runtime optional;
        };
    in builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
    checkOne = dp: {
      name  = dp.ident;
      value = let
        haves = if dp.runtime then rtDIs else pdef.depInfo;
        bads  = removeAttrs dp.peerInfo ( builtins.attrNames haves );
        part  = builtins.partition ( i: pdef.depInfo ? ${i} )
                                   ( builtins.attrNames bads );
      in {
        inherit (dp) runtime optional;
        missing = if dp.runtime then removeAttrs bads part.right else bads;
        moves   = if dp.runtime then removeAttrs bads part.wrong else {};
      };
    };
    checkAll = let
      pred = v: ( v.value.missing != {} ) || ( v.value.moves != {} );
    in builtins.filter pred ( map checkOne deps );
  in builtins.listToAttrs checkAll;

  # Checks
  checkPeersPresent = lib.libfloco.runNVFunction {
    modify = false;
    fn     = checkPeersPresent';
  };


# ---------------------------------------------------------------------------- #

  # Process the result of `checkPeersPresent' into a human readable report.
  # First argument `name' is used to mark issues for use in a collection.
  describeCheckPeersPresentEnt = name: {
    runtime  ? false
  , optional ? false
  , missing  ? {}
  , moves    ? {}
  , ...
  }: let
    need     = o: if optional || o then "may be required" else "is required";
    when     = if runtime then "runtime" else "dev";
    descMove = di: { descriptor ? "*", optional ? false, ... }:
      "  + `${di}' is marked `dev', but ${need optional} in `runtime'";
    descMiss = di: { descriptor ? "*", optional ? false, ... }:
      "  + `${di}@${descriptor}' ${need optional} in `${when}'";
    moveMsgs = if ! runtime then [] else
               builtins.attrValues ( builtins.mapAttrs descMove moves );
    missMsgs = builtins.attrValues ( builtins.mapAttrs descMiss missing );
    msgs     = builtins.concatStringsSep "\n" ( missMsgs ++ moveMsgs );
    opt      = if optional then "" else " optional";
    okMsg    = "- `${name}' (${when}${opt}) is okay";
    badMsg   = "- `${name}' (${when}${opt}) may have `peer' issues:\n${msgs}";
  in if ( missing == {} ) && ( moves == {} ) then okMsg else badMsg;

  # Process an attrset of results from `checkPeersPresent' into a human
  # readable report.
  # Attribute names are used to mark issues.
  describeCheckPeersPresent = checked:
    builtins.concatStringsSep "\n\n" ( builtins.attrValues (
      builtins.mapAttrs lib.libfloco.describeCheckPeersPresentEnt checked
    ) );


# ---------------------------------------------------------------------------- #

  # Assert that all paths in `tree' have a parent path.
  # `tree' may be an attrset keyed by paths, or a list of paths.
  auditTreePathParents = tree: let
    asAttrs =
      if builtins.isAttrs tree then tree else
      builtins.listToAttrs ( map ( name: { inherit name; value = null; } )
                                 tree );
    pred = path: asAttrs ? ${lib.libfloco.nmParent path};
  in builtins.all pred (
    if builtins.isList tree then tree else builtins.attrNames tree
  );


# ---------------------------------------------------------------------------- #

  # Run a closure operation over a `tree' using predicates to effectively
  # "filter out" some paths.
  runTreeClosure = {
    rootPath    ? ""
  , rootPred    ? { ckey = "dev"; __functor = _: _: true; }
  , childPred   ? { ckey = "runtime"; __functor = _: de: de.runtime; }
  , addRoot     ? true
  , outputStyle ? "paths"
  , audit       ? true
  , tree
  }: let
    getChildDeps = let
      p = lib.libfloco.getDepsWith childPred;
      f = p.__functor p;
    in if p ? __functor then builtins.deepSeq f f else p;
    closure = builtins.genericClosure {
      operator = { key }: let
        needs     = getChildDeps tree.${key};
        fromScope = builtins.intersectAttrs needs tree.${key}.scope;
      in lib.mapAttrsToList ( _: s: { key = s.path; } ) fromScope;
      startSet = let
        needs     = lib.libfloco.getDepsWith rootPred tree.${rootPath};
        fromScope = builtins.intersectAttrs needs tree.${rootPath}.scope;
      in lib.mapAttrsToList ( _: s: { key = s.path; } ) fromScope;
    };
    wroot = let
      hasRoot = builtins.any ( v: v.key == rootPath ) closure;
    in if ( ! addRoot ) || hasRoot then closure else
       [{ key = rootPath; }] ++ closure;
    pathOutput = map ( e: e.key ) wroot;

    checkParentPaths = x: let
      ok = ( ! audit ) || ( auditTreePathParents ( pathOutput ++ [""] ) );
    in if ok then x else
       throw ( "lib.libfloco.runTreeClosure: Filtered tree has dangling paths:"
               + ( lib.generators.toPretty {} pathOutput ) );
    checkHasRoot = x:
      if tree ? ${rootPath} then x else
      throw ( "lib.libfloco.runTreeClosure: root path `${rootPath}` does not " +
              "exist in given tree." );
    check = x: checkParentPaths ( checkHasRoot x );

    output = if outputStyle == "paths" then pathOutput else
             throw ( "lib.libfloco.runTreeClosure: " +
                     "Unrecognized `outputStyle': \"${outputStyle}\"." );
  in assert tree ? ${rootPath};
     check output;


# ---------------------------------------------------------------------------- #

in {

  inherit
    mkDepInfoEntryPred
    depInfoEntryPred
    mkDepInfoEntryPredOption
  ;
  mkDEPred = mkDepInfoEntryPred;

  inherit
    pdefClosureFunctorInterfaceDeferred  # Exposed for documentation
    pdefClosureFunctorWith
    pdefClosureFunctor
    mkPdefClosureFunctor
    pdefClosureWith
    pdefClosure
  ;

  inherit
    pdefClosureCachedFunctorImplementationDeferred
    pdefClosureCachedFunctor
    mkPdefClosureCachedFunctor
  ;

  inherit
    getDepsWith
    getRuntimeDeps
    getDevDeps
  ;

  inherit
    checkPeersPresent
    describeCheckPeersPresentEnt
    describeCheckPeersPresent
  ;

  inherit
    auditTreePathParents
    runTreeClosure
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
