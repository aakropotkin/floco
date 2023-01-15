# ============================================================================ #
#
# Arguments used to fetch a source tree or github.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../../fetchInfo/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  options.fetchTree_github = lib.mkOption {
    type = nt.submodule { imports = [fetcher]; };
  };


# ---------------------------------------------------------------------------- #

  config.fetchTree_github = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault builtins.fetchTree;


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        sourceInfo = config.fetchTree_github.function ( {
          type = "github";
          inherit (fetchInfo) owner repo ref;
        } // ( if ( fetchInfo.rev or null ) == null then {} else {
          inherit (fetchInfo) rev;
        } ) );
        narHash' = if ( fetchInfo.narHash or null ) != null then {} else {
          inherit (sourceInfo) narHash;
        };
        rev' = if ( fetchInfo.rev or null ) != null then {} else {
          inherit (sourceInfo) rev;
        };
      in fetchInfo // narHash' // rev'
    );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo = lib.mkDefault ( _file: fetchInfo: let
      nd = lib.moduleDropDefaults config.fetchTree_github.fetchInfo fetchInfo;
    in ( removeAttrs nd ["narHash"] ) // { type = "github"; } );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s:
      if builtins.isAttrs s then s else throw (
        "floco:fetchTree[github]: Deserialization from string " +
        "has not been implemented ( TODO )"
      )
    );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["github"];
              default = "github";
            };
            owner = lib.mkOption { type = nt.str; };
            repo  = lib.mkOption { type = nt.str; };
            rev   = lib.mkOption {
              type    = nt.nullOr nt.str;
              default = null;
            };
            ref     = lib.mkOption { type = nt.str; default = "HEAD"; };
            narHash = lib.mkOption ( {
              type = if fetchers.config.fetchTree_github.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTree_github.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.rev = let
            locked = fetchers.config.fetchTree_github.lockFetchInfo {
              type = "github";
              inherit (config) owner repo ref;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_github.pure ) (
            lib.mkDefault locked.rev
          );

          config.narHash = let
            locked = fetchers.config.fetchTree_github.lockFetchInfo {
              type = "github";
              inherit (config) owner repo ref rev;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_github.pure ) (
            lib.mkDefault locked.narHash
          );

        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTree_github'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
