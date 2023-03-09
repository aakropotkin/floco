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

  # Typed
  depInfoEntryPred = let
    fargs = { runtime = null; dev = null; optional = null; bundled = null; };
    fromT = nt.addCheck ( nt.attrsOf ( nt.nullOr nt.bool ) )
                        ( a: ( builtins.intersectAttrs fargs a ) == a );
  in nt.coercedTo fromT mkDepInfoEntryPred ( nt.functionTo nt.bool );

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

  getDepsWith = predlike: x: let
    pred = if lib.isFunction predlike then predlike else
           lib.libfloco.mkDepInfoEntryPred predlike;
  in lib.filterAttrs ( ident: entry: pred ( { inherit ident; } // entry ) )
                     ( x.depInfo or x );

  getRuntimeDeps = { optional ? null, bundled ? null } @ mask:
    lib.libfloco.getDepsWith ( mask // { runtime = true; } );

  getDevDeps = { optional ? null, bundled ? null } @ mask:
    getDepsWith ( mask // { dev = true; } );


# ---------------------------------------------------------------------------- #

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
        default = _: true;
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
        readOnly = true;
      };

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
      };

    };  # End `options'
  };  # End `pdefClosureFunctorInterfaceDeferred'


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
      in {
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

      __functor = self: let
        mkStartSet = self._private.__mkStartSet self;
        operator   = self._private.__operator   self;
        # handleStyle :: [entries] -> <STYLE>
        handleStyle = self._private._handleStyle self.outputStyle;
      in keylike: let
        root    = self.getPdef self.payload keylike;
        closure = builtins.genericClosure {
          inherit operator;
          startSet = mkStartSet root;
        };
        wroot = let
          hasRoot = builtins.any ( v: v.key == root.key ) closure;
        in if ( ! self.addRoot ) || hasRoot then closure else [root] ++ closure;
      in handleStyle ( map self.mkEntry wroot );
    };
  };

  pdefClosureFunctorWith = extra: let
    extraModules =
      if builtins.isList extra then extra else
      if builtins.isFunction extra then [extra] else
      if ( extra ? config ) || ( extra ? _module ) then [extra] else
      if ! ( extra ? pdefs ) then [{ config = extra; }] else [{
        config = ( removeAttrs extra ["pdefs"] ) // {
          payload = ( extra.payload or {} ) // { inherit (extra) pdefs; };
        };
      }];
  in nt.submodule ( [
    pdefClosureFunctorInterfaceDeferred
    pdefClosureFunctorImplementationDeferred
  ] ++ extraModules );

  pdefClosureFunctor = pdefClosureFunctorWith [];


# ---------------------------------------------------------------------------- #

  pdefClosure' = pdefs: keylike: let
    mkNode = builtins.intersectAttrs {
      key     = true; ident    = true; version  = true;
      depInfo = true; peerInfo = true;
    };
    get = ident: { pin, ... }: let
      full = lib.libfloco.getPdef { inherit pdefs; } {
        inherit ident; version = pin;
      };
    in mkNode full;
    operator = pdef: builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
  in builtins.genericClosure {
    startSet = operator ( mkNode ( lib.libfloco.getPdef pdefs keylike ) );
    inherit operator;
  };

  pdefClosure = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosure' pdefs keylike;


# ---------------------------------------------------------------------------- #

  pdefClosureWith' = rootPred: pred: pdefs: keylike: let
    rootPdef = lib.libfloco.getPdef pdefs keylike;
    filterDeps = pdef: pdef // {
      depInfo = if rootPdef.key == pdef.key then getDepsWith rootPred pdef else
                getDepsWith pred pdef;
    };
    filtered = map filterDeps ( ( pdefClosure' pdefs keylike ) ++ [rootPdef] );
    pdefs'   = lib.libfloco.pdefsFromList filtered;
  in pdefClosure' pdefs' keylike;

  pdefClosureWith = rootPred: pred: {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosureWith' rootPred pred pdefs keylike;


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

  checkPeersPresent = lib.libfloco.runNVFunction {
    modify = false;
    fn     = checkPeersPresent';
  };


# ---------------------------------------------------------------------------- #

  describeCheckPeersPresentEnt = ident: {
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
    okMsg    = "- `${ident}' (${when}${opt}) is okay";
    badMsg   = "- `${ident}' (${when}${opt}) may have `peer' issues:\n${msgs}";
  in if ( missing == {} ) && ( moves == {} ) then okMsg else badMsg;

  describeCheckPeersPresent = checked:
    builtins.concatStringsSep "\n\n" ( builtins.attrValues (
      builtins.mapAttrs lib.libfloco.describeCheckPeersPresentEnt checked
    ) );


# ---------------------------------------------------------------------------- #

in {

  inherit
    mkDepInfoEntryPred
    depInfoEntryPred
    mkDepInfoEntryPredOption
  ;
  mkDEPred = mkDepInfoEntryPred;

  inherit
    pdefClosureFunctorInterfaceDeferred
    pdefClosureFunctorImplementationDeferred
    pdefClosureFunctorWith
    pdefClosureFunctor
  ;

  inherit
    getDepsWith
    getRuntimeDeps
    getDevDeps
  ;

  inherit
    pdefClosure
    pdefClosureWith

    checkPeersPresent
    describeCheckPeersPresentEnt
    describeCheckPeersPresent
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
