# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../../fetchInfo/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  options.fetchTree_tarball = lib.mkOption {
    type = nt.submodule { imports = [fetcher]; };
  };


# ---------------------------------------------------------------------------- #

  config.fetchTree_tarball = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault builtins.fetchTree;


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        sourceInfo = config.fetchTree_tarball.function {
          type = "tarball";
          inherit (fetchInfo) url;
        };
        narHash' = if ( fetchInfo.narHash or null ) != null then {} else {
          inherit (sourceInfo) narHash;
        };
      in fetchInfo // narHash'
    );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo   = lib.mkDefault ( _file: fetchInfo: fetchInfo );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
        m    = builtins.match "([^?]+)\\?([^?]+)" s;
        path = builtins.head m;
        prms = builtins.elemAt m 1;
        ps   = builtins.filter builtins.isString ( builtins.split "&" prms );
        mnhp = builtins.filter ( lib.hasPrefix "narHash=" ) ps;
        nhp  = builtins.head mnhp;
        nh'  = if ( m == null ) || ( mnhp == [] ) then {} else {
          narHash = builtins.head ( builtins.match "narHash=(.*)" nhp );
        };
      in if builtins.isAttrs s then s else {
        type = "tarball";
        url  = let
          mf = builtins.match "tarball\\+(.*)" s;
        in if mf == null then s else builtins.head mf;
      } // nh'
    );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["tarball"];
              default = "tarball";
            };
            url     = lib.mkOption { type = nt.str; };
            narHash = lib.mkOption ( {
              type = if fetchers.config.fetchTree_tarball.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTree_tarball.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.narHash = let
            locked = fetchers.config.fetchTree_tarball.lockFetchInfo {
              type = "tarball";
              inherit (config) url;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_tarball.pure ) (
            lib.mkDefault locked.narHash
          );

        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTree_tarball'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
