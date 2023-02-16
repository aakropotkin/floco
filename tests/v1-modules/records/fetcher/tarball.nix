# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../../../../lib {} }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  v1-mods = lib.evalModules { modules = [../../../../v1-modules]; };

  mkFetcherOption = v1-mods.config.stage1.config.records.fetcher.mkOpt;


# ---------------------------------------------------------------------------- #

  fmodule = {
    options.tarballFetcher = mkFetcherOption "fetchTarball";
    config.tarballFetcher  = {

      info = {
        name      = "fetchTarball";
        pure      = true;
        systemIFD = false;
      };

      lockFetchInfo = fetchInfo: let
        args = lib.filterAttrs ( _: v: v != null ) ( builtins.intersectAttrs {
          url    = false;
          sha256 = true;
        } fetchInfo );
        outPath    = builtins.fetchTarball args;
        sourceInfo = builtins.fetchTree {
          type = "path";
          path = outPath;
        };
      in fetchInfo // {
        sha256 =
          if ( fetchInfo.sha256 or fetchInfo.narHash or null ) != null
          then fetchInfo.sha256 or fetchInfo.narHash
          else sourceInfo.narHash;
      };

      deserializeFetchInfo = fetchInfo: {
        type   = "tarball";
        sha256 = fetchInfo.narHash;
      } // fetchInfo;

      fetchInfo = nt.submodule {
        options = {
          url    = lib.mkOption { type = nt.str; };
          sha256 = lib.mkOption { type = nt.nullOr nt.str; default = null; };
        };
      };

      input = nt.strMatching "(tarball+(https:/)?)?/.*";

      function = { url, sha256 ? args.narHash, ... } @ args: let
        s = if sha256 == null then {} else { inherit sha256; };
      in builtins.fetchTarball ( s // { inherit url; } );

    };
  };

  fmod = lib.evalModules { modules = [fmodule]; };


# ---------------------------------------------------------------------------- #

  umodule = { config, options, ... }: {

    options.fetchInfo = lib.mkOption {
      type = fmod.config.tarballFetcher.fetchInfo;
    };

    options.locked = lib.mkOption {
      type = fmod.config.tarballFetcher.fetchInfo;
    };

    options.source = lib.mkOption { type = nt.package; };


    config.fetchInfo = {
      url    = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
      sha256 = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
    };

    config.locked =
      lib.mkDerivedConfig options.fetchInfo
                          fmod.config.tarballFetcher.lockFetchInfo;

    config.source = lib.mkDerivedConfig options.fetchInfo
                                        fmod.config.tarballFetcher.function;

  };


# ---------------------------------------------------------------------------- #

in {

  inherit fmod umodule;
  umod = lib.evalModules { modules = [umodule]; };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
