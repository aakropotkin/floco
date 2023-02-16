# ============================================================================ #
#
# A `options.floco.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib
, options
, config
, pkgs
, fetchers
, pdefs

, basedir
, deriveTreeInfo

# Used by `depInfo'
, requires
, dependencies
, devDependencies
, devDependenciesMeta
, optionalDependencies
, bundledDependencies
, bundleDependencies

, ...
}: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/implementation.nix";

  imports = [
    ./binInfo/implementation.nix
    ./treeInfo/implementation.nix
    ./peerInfo/implementation.nix
    ./sysInfo/implementation.nix
    ./fsInfo/implementation.nix
    ./lifecycle/implementation.nix
  ];


# ---------------------------------------------------------------------------- #

  options.fetcher = lib.mkOption {
    internal = true;
    visible  = false;
    type     = nt.enum ( builtins.attrNames ( removeAttrs fetchers ["pure"] ) );
    default  = "composed";
  };

  options.fetchInfo = let
    mkFetchInfoType = fetcher: let
      coerce = _file: fi: fetcher.deserializeFetchInfo _file fi;
    in ( nt.coercedTo nt.str ( coerce "<phony>" ) fetcher.fetchInfo ) // {
      inherit (fetcher.fetchInfo) description __toString name;
      inherit (nt.either nt.str fetcher.fetchInfo) check;
      substSubModules = m: mkFetchInfoType ( fetcher // {
        fetchInfo = fetcher.fetchInfo.substSubModules m;
      } );
      merge = loc: defs: let
        coerced = map ( { file, value, ... } @ def: def // {
          value = if builtins.isAttrs value then value else
                  fetcher.deserializeFetchInfo file value;
        } ) defs;
      in fetcher.fetchInfo.merge loc coerced;
    };
  in lib.mkOption { type = mkFetchInfoType fetchers.${config.fetcher}; };


# ---------------------------------------------------------------------------- #

  config = let

    depInfoArgs = let
      raw  = { requires = {}; } // ( config.metaFiles.pjs or {} );
      args = builtins.intersectAttrs {
        dependencies         = true;
        devDependencies      = true;
        devDependenciesMeta  = true;
        optionalDependencies = true;
        bundledDependencies  = true;
        bundleDependencies   = true;
      } ( config.metaFiles.pjs or {} );
    in if config.deserialized then {} else
       builtins.mapAttrs ( _: lib.mkOverride 1100 ) args;

  in {

# ---------------------------------------------------------------------------- #

    _module.args = depInfoArgs // {
      basedir = let
          isExt = f:
            ( ! ( lib.hasPrefix "<floco>/" f ) ) &&
            ( f != "<unknown-file>" ) &&
            ( f != "lib/modules.nix" );
          dls  = map ( v: v.file ) options.fetchInfo.definitionsWithLocations;
          exts = builtins.filter isExt dls;
          val  = if exts != [] then dirOf ( builtins.head exts ) else
                config.fetchInfo.path or config.metaFiles.pjsDir;
        in lib.mkDefault val;

      deriveTreeInfo = lib.mkDefault false;
    };


# ---------------------------------------------------------------------------- #

    deserialized = lib.mkDefault (
      builtins.any ( v: builtins.elem ( baseNameOf v.file ) [
        "pdefs.nix"      "pdefs.json"
        "foverrides.nix" "foverrides.json"
        "floco-cfg.nix"  "floco-cfg.json"
      ] ) options.ltype.definitionsWithLocations
    );


# ---------------------------------------------------------------------------- #

    ident = lib.mkDefault (
      config.metaFiles.metaRaw.ident or config.metaFiles.pjs.name or
      ( dirOf config.key )
    );

    version = lib.mkDefault (
      config.metaFiles.metaRaw.version or config.metaFiles.pjs.version or
      ( baseNameOf config.key )
    );

    key = lib.mkDefault (
      config.metaFiles.metaRaw.key or ( config.ident + "/" + config.version )
    );


# ---------------------------------------------------------------------------- #

    # These are the oddballs.
    # `fetchInfo` is polymorphic - it is conventionally declared using
    # `fetcher.fetchInfo', and defined by the user, a discoverer,
    # or a translator.
    # This abstraction allows users to add their own fetchers, or customize
    # the behavior of existing fetchers at the expense of making things harder
    # to read and understand.
    #
    # When in doubt or if you get frustrated - remember that you can always set
    # `floco.packages.*.*.source` directly and set any other `pdef' fields that
    # are relevant to the build plan.
    # While these abstractions may be bit of a headache, they're necessary to
    # allow the `floco' framework to be extensible.

    fetchInfo = let
      default = builtins.mapAttrs ( _: lib.mkDefault ) ( {
        type = "tarball";
        url  = let
          bname = baseNameOf config.ident;
          inherit (config) version;
        in "https://registry.npmjs.org/${config.ident}/-/" +
            "${bname}-${version}.tgz";
      } // ( config.metaFiles.metaRaw.fetchInfo or {} ) );
    in lib.mkDefault default;

    sourceInfo = let
      type    = config.fetchInfo.type or "path";
      fetched = fetchers.${config.fetcher}.function config.fetchInfo;
      src     = if type != "file" then fetched else builtins.fetchTarball {
        url = "file:${builtins.unsafeDiscardStringContext fetched}";
      };
    in lib.mkDefault ( if type == "file" then { outPath = src; } else src );


# ---------------------------------------------------------------------------- #

    ltype = lib.mkDefault (
      if config.fetchInfo ? path then "dir" else
      if builtins.elem config.fetchInfo.type ["file" "tarball"] then "file" else
      "git"
    );


# ---------------------------------------------------------------------------- #

    metaFiles.pjsDir = let
      dp  =
        if ! ( builtins.elem ( config.fsInfo.dir or "." ) ["." "./." "" null] )
        then "/" + config.fsInfo.dir
        else "";
      projDir = config.fetchInfo.path or config.sourceInfo.outPath;
    in lib.mkDefault (
      if ! config.deserialized then projDir + dp else
      throw ( "floco: `${config.key}' attempting to reference " +
              "`metaFiles.pjsDir' from deserialized form." )
    );

    metaFiles.pjs = let
      pjsPath = config.metaFiles.pjsDir + "/package.json";
      pjs     = lib.importJSON pjsPath;
    in lib.mkDefault ( if config.deserialized then {} else pjs );


# ---------------------------------------------------------------------------- #

  # TODO: in order to handle relative paths in a sane way this routine really
  # needs to be outside of the module fixed point, and needs to accept an
  # argument indicating `basedir' to make paths relative from.
  # This works for now but I really don't like it.
  _export = lib.mkMerge [
    {
      inherit (config) ident version ltype;
      fetchInfo =
        fetchers.${config.fetcher}.serializeFetchInfo basedir
                                                      config.fetchInfo;
    }
    ( lib.mkIf ( config.key != "${config.ident}/${config.version}" ) {
      inherit (config) key;
    } )
  ];


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
