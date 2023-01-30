# ============================================================================ #
#
# Arguments used to fetch a source tree using `git'.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/fetcher/fetchTree/git/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.fetchTree_git = lib.mkOption {
    type = nt.submodule { imports = [fetcher]; };
  };


# ---------------------------------------------------------------------------- #

  config.fetchTree_git = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault builtins.fetchTree;


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        sourceInfo = config.fetchTree_git.function ( {
          type = "git";
          inherit (fetchInfo) url allRefs shallow submodules ref;
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
      nd = lib.moduleDropDefaults config.fetchTree_git.fetchInfo fetchInfo;
    in ( removeAttrs nd ["narHash"] ) // { type = "git"; } );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
      m    = builtins.match "(git\\+)?([^?]+)(\\?([^?]+))?" s;
      path = builtins.elemAt m 1;
      prms = builtins.elemAt m 3;
      ps   = if prms == null then [] else
             builtins.filter builtins.isString ( builtins.split "&" prms );
      pp  = builtins.partition ( lib.hasPrefix "narHash=" ) ps;
      nhp = builtins.head pp.right;
      nh' = if ( ( builtins.elemAt m 2 ) == null ) || ( pp.right == [] )
            then {} else {
              narHash = builtins.head ( builtins.match "narHash=(.*)" nhp );
            };
      pnh = if pp.wrong == [] then "" else
            "?" + ( builtins.concatStringsSep "&" pp.wrong );
    in if builtins.isAttrs s then s else {
      type = "git";
      url  = "git+" + path + pnh;
    } // nh' );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["git"];
              default = "git";
            };
            url        = lib.mkOption { type = nt.str; };
            allRefs    = lib.mkOption { type = nt.bool; default = false; };
            shallow    = lib.mkOption { type = nt.bool; default = false; };
            submodules = lib.mkOption { type = nt.bool; default = false; };
            rev        = lib.mkOption {
              type    = nt.nullOr ft.rev;
              default = null;
            };
            ref     = lib.mkOption { type = nt.str; default = "HEAD"; };
            narHash = lib.mkOption ( {
              type = if fetchers.config.fetchTree_git.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTree_git.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.rev = let
            locked = fetchers.config.fetchTree_git.lockFetchInfo {
              type = "git";
              inherit (config) url allRefs shallow submodules ref;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_git.pure ) (
            lib.mkDefault locked.rev
          );

          config.narHash = let
            locked = fetchers.config.fetchTree_git.lockFetchInfo {
              type = "git";
              inherit (config) url allRefs shallow submodules ref rev;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_git.pure ) (
            lib.mkDefault locked.narHash
          );

        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

    input = lib.mkDefault ( nt.strMatching "git(\\+(ssh|https))?://.*" );


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTree_git'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
