# ============================================================================ #
#
# Arguments used to fetch a source tree from github.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = lib.libfloco;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/fetcher/fetchTree/github/implementation.nix";

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
    in ( removeAttrs nd ["narHash" "revOrRef"] ) // { type = "github"; } );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
      m  = builtins.match "github:([^/]+)/([^/]+)(/(.*))?" s;
      rr = builtins.elemAt m 3;
    in if builtins.isAttrs s then s else {
      owner    = builtins.head m;
      repo     = builtins.elemAt m 1;
      revOrRef = if rr == null then "HEAD" else rr;
    } );


# ---------------------------------------------------------------------------- #

    # TODO: enforce `pure' with a `check'.
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
              type    = nt.nullOr ft.rev;
              default = null;
            };
            ref     = lib.mkOption { type = nt.str; default = "HEAD"; };
            narHash = lib.mkOption {
              type    = nt.nullOr ft.narHash;
              default = null;
            };
            revOrRef = lib.mkOption {
              internal = true;
              visible  = false;
              type     = nt.either ft.rev nt.str;
            };
          };  # End `fetchInfo.options'

          config.revOrRef = lib.mkDefault (
            if config.rev != null then config.rev else config.ref
          );

          # TODO: from `revOrRef'
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

    input = lib.mkDefault ( nt.strMatching "github:[^/]+/[^/]+(/.*)?" );


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTree_github'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
