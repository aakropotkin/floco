# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

  imports = [config.fetcher];

  config.path = { config, ... }: {

    config.function = lib.mkDefault builtins.path;

    config.lockFetchInfo = lib.mkDefault ( fetchInfo: let
        outPath = config.function {
          inherit (fetchInfo) name path filter recursive;
        };
        sourceInfo = builtins.fetchTree {
          type = "path";
          path = outPath;
        };
      in { sha256 = sourceInfo.narHash; } // fetchInfo
    );

    serializeFetchInfo = lib.mkDefault ( _file: fetchInfo: let
      subs  = config.fetchInfo.getSubOptions [];
      name' = if fetchInfo.name == subs.name.default then {} else {
        inherit (fetchInfo) name;
      };
    in name' // {
      sha256 = if fetchInfo.sha256 != null then fetchInfo.sha256 else
               ( config.lockFetchInfo fetchInfo ).sha256;
      # TODO: realpath
      path = if ! ( lib.hasPrefix "/" ( toString fetchInfo.path )
             then fetchInfo.path
             else builtins.replaceStrings [_file] ["."] fetchInfo.path;
    } );

    deserializeFetchInfo = _file: fetchInfo: /* TODO */ fetchInfo;

    config.fetchInfo = nt.submodule {
      options = {
        sha256 = lib.mkOption ( {
          type = let
            base = nt.either ft.sha256_hash ft.sha256_sri;
          in if config.pure then base else nt.nullOr base;
        } // ( if config.pure then {} else { default = null; } ) );
      };  # End `fetchInfo.options'
    };

  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
