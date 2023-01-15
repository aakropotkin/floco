# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../fetchInfo/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  options.path = lib.mkOption {
    type = nt.submodule { imports = [fetcher]; };
  };


# ---------------------------------------------------------------------------- #

  config.path = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault builtins.path;

# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        outPath = config.path.function {
          inherit (fetchInfo) name path filter recursive;
        };
        sourceInfo = builtins.fetchTree {
          type = "path";
          path = outPath;
        };
        sha256' = if ( fetchInfo.sha256 or null ) != null then {} else {
          sha256 = sourceInfo.narHash;
        };
      in fetchInfo // sha256'
    );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo = lib.mkDefault ( _file: fetchInfo: let
      keeps = let
        serializable = removeAttrs fetchInfo ["filter"];
      in lib.moduleDropDefaults config.path.fetchInfo serializable;
    in keeps // {
      sha256 = if fetchInfo.sha256 != null then fetchInfo.sha256 else
               ( config.path.lockFetchInfo fetchInfo ).sha256;
      path = lib.realpathRel ( dirOf _file ) fetchInfo.path;
    } );

# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: fetchInfo:
      fetchInfo // {
        path = if lib.isAbspath fetchInfo.path then fetchInfo.path else
              ( dirOf _file ) + ( "/" + fetchInfo.path );
      } );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            name   = lib.mkOption { type = nt.str; default = "source"; };
            path   = lib.mkOption { type = nt.path; };
            filter = lib.mkOption {
              type    = nt.functionTo ( nt.functionTo nt.bool );
              default = name: type: true;
            };
            recursive = lib.mkOption { type = nt.bool; default = true; };
            sha256    = lib.mkOption ( {
              type = let
                base = nt.either ft.sha256_hash ft.sha256_sri;
              in if fetchers.config.path.pure then base else nt.nullOr base;
            } // ( if fetchers.config.path.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.sha256 = let
            locked = fetchers.config.path.lockFetchInfo {
              inherit (config) name path filter recursive;
            };
          in lib.mkIf ( ! fetchers.config.path.pure ) (
            lib.mkDefault locked.sha256
          );
        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

  };  # End `config.path'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
