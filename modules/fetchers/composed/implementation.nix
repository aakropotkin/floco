# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/composed/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.composed = lib.mkOption {
    type = nt.submodule {
      imports = [fetcher];

      options.subs = lib.mkOption {
        description = lib.mdDoc ''
          Inner/child fetchers which may be called to perform real operations.
        '';
        type = nt.submodule {
          freeformType = nt.attrsOf ( nt.submodule { imports = [fetcher]; } );

          options.path = lib.mkOption {
            description = lib.mdDoc ''
              Fetcher used for local filesystem paths.
            '';
            type    = nt.submodule { imports = [fetcher]; };
            default = config.path;
          };

          options.tarball = lib.mkOption {
            description = lib.mdDoc ''
              Fetcher used for unpacking tarballs.
              Tarballs may be local files or remote URLs.
            '';
            type    = nt.submodule { imports = [fetcher]; };
            default = config.fetchTree_tarball;
          };

          options.file = lib.mkOption {
            description = lib.mdDoc ''
              Fetcher used for fetching files from remote URLs.
            '';
            type    = nt.submodule { imports = [fetcher]; };
            default = config.fetchTree_file;
          };

          options.git = lib.mkOption {
            description = lib.mdDoc ''
              Fetcher used to clone source trees from `git`.
            '';
            type    = nt.submodule { imports = [fetcher]; };
            default = config.fetchTree_git;
          };

          options.github = lib.mkOption {
            description = lib.mdDoc ''
              Fetcher used to clone source trees from GitHub.
              This is an optimized form of the `git` fetcher.
            '';
            type    = nt.submodule { imports = [fetcher]; };
            default = config.fetchTree_git;
          };

        };  # End `options.composed.type.options.subs.type'

        default = {};

      };  # End `options.composed.type.options.subs'

      options.identifyFetcher = lib.mkOption {
        description = lib.mdDoc ''
          Function which identifies which sub-fetcher will be used for a given
          `fetchInfo` input.

          This routine accepts a single argument with must be either a
          serialized string form of `fetchInfo` or an attrset form
          of `fetchInfo`.

          This function returns a string, being the attribute name of a
          sub-fetcher as `subs.<NAME>`.
        '';
        type = nt.functionTo nt.str;
      };

    };  # End `options.composed.type'
  };  # End `options.composed'


# ---------------------------------------------------------------------------- #

  config.composed = let
    cfg = config.composed;
  in {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

# ---------------------------------------------------------------------------- #

    identifyFetcher = let
      fromStr   = str:   builtins.head ( builtins.match "([^+:]+)[+:].*" str );
      fromAttrs = attrs: attrs.type or "path";
      fn = fi: let
        sf = if builtins.isString fi then fromStr fi else fromAttrs fi;
      in assert cfg.pure -> cfg.subs.${sf}.pure; sf;
    in lib.mkDefault fn;


# ---------------------------------------------------------------------------- #

    function = let
      fn = fi: let
        sf   = cfg.subs.${cfg.identifyFetcher fi};
        args = let
          so = removeAttrs ( sf.getSubOptions [] ) ["_module"];
        in builtins.intersectAttrs so fi;
      in sf.function args;
    in lib.mkDefault fn;


# ---------------------------------------------------------------------------- #

    lockFetchInfo = let
      fn = fi: cfg.subs.${cfg.identifyFetcher fi}.lockFetchInfo fi;
    in lib.mkDefault fn;


# ---------------------------------------------------------------------------- #

    serializeFetchInfo = let
      fn = _file: fetchInfo:
        cfg.subs.${cfg.identifyFetcher fetchInfo}.serializeFetchInfo fetchInfo;
    in lib.mkDefault fn;


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = let
      fn = _file: fetchInfo: let
        sf = cfg.identifyFetcher fetchInfo;
      in cfg.subs.${sf}.deserializeFetchInfo fetchInfo;
    in lib.mkDefault fn;


# ---------------------------------------------------------------------------- #

    fetchInfo = let
      subFis          = builtins.mapAttrs ( _: f: f.fetchInfo ) cfg.subs;
      mkFetchInfoType = subs: let
        self = {
          name        = "fetchInfo (composed)";
          description = lib.mdDoc ''
            Arguments passed underlying fetchers, and optionally the field
            `type` used to manually indicate which sub-fetcher should be used.
          '';
          descriptionClass = "composite";
          check = x:
            builtins.any ( s: s.check x )
                         ( builtins.attrValues self.nestedTypes );
          nestedTypes = subs;
          typeMerge   = f': let
            mts = builtins.mapAttrs ( n: s:
              self.nestedTypes.${n}.typeMerge s.functor
            ) f'.wrapped;
            anyNull = builtins.any ( s: s == null ) ( builtins.attrValues mts );
          in if self.name != f'.name then null else
             if anyNull then null else
             ( mkFetchInfoType mts );
          functor = {
            inherit (self) name;
            type = self;
            wrapped = self.nestedTypes;
            payload = null;
            binOp   = a: b: null;  # TODO
          };
          merge = loc: defs: let
            types = map ( def: cfg.identifyFetcher def.value ) defs;
            type  = let
              ft = builtins.head types;
            in if builtins.all ( t: ft == t ) types then ft else
               throw (
                 "The option `${lib.showOption loc}` is defined multiple " +
                 "times with conflicting fetcher types in " +
                 ( lib.showFiles ( lib.getFiles defs ) )
               );
          in subs.${type}.merge loc defs;
        };
      in lib.mkOptionType self;
    in lib.mkDefault ( mkFetchInfoType subFis );


# ---------------------------------------------------------------------------- #

  };  # End `config.path'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
