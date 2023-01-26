# ============================================================================ #
#
# Arguments used to fetch a file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../../types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/fetcher/fetchTree/file/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.fetchTree_file = lib.mkOption {
    type = nt.submodule {
      imports = [fetcher];

      options.serializerStyle = lib.mkOption {
        description = lib.mdDoc ''
          Preferred serialization style used to write lockfiles.
          - `string` writes `fetchInfo` to a URI string equivalent to the one
            used for `flake` inputs.
          - `attrs` emits `fetchInfo` as an attribute set, dropping some fields
            if they can be inferred by `deserializeFetchInfo`.

          Note that the function `deserializeFetchInfo` must be able to read
          either form regardless of how this option is set.
        '';
        type    = nt.enum ["string" "attrs"];
        default = "attrs";
        example = "string";
      };

      options.serializeFetchInfo_string = lib.mkOption {
        type     = nt.functionTo ( nt.functionTo nt.str );
        internal = true;
        visible  = false;
      };
      options.serializeFetchInfo_attrs = lib.mkOption {
        type     = nt.functionTo ( nt.functionTo ( nt.attrsOf lib.jsonAtom ) );
        internal = true;
        visible  = false;
      };

    };  # End `options.fetchTree_file.type'
  };


# ---------------------------------------------------------------------------- #

  config.fetchTree_file = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault builtins.fetchTree;


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        sourceInfo = config.fetchTree_file.function {
          type = "file";
          inherit (fetchInfo) url;
        };
        narHash' = if ( fetchInfo.narHash or null ) != null then {} else {
          inherit (sourceInfo) narHash;
        };
      in fetchInfo // narHash'
    );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_string = lib.mkDefault ( _file: fetchInfo: let
      pre = let
        m = builtins.match "file\\+.*" fetchInfo.url;
      in if m == null then "file+" else "";
      psep =
        if ( builtins.match ".*\\?.*" fetchInfo.url ) == null then "?" else "&";
      post = let
        mh = builtins.match "[^?]+\\?([^?]+&)?narHash=[^&]+(&[^?]+)?"
                            fetchInfo.url;
      in if ( mh != null ) || ( ( fetchInfo.narHash or null ) == null )
         then ""
         else psep + "narHash=" + fetchInfo.narHash;
    in pre + fetchInfo.url + post );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_attrs = lib.mkDefault ( _file: fetchInfo: let
      nh' = if ( fetchInfo.narHash or null ) == null then {} else {
        inherit (fetchInfo) narHash;
      };
    in nh' // { type = "file"; inherit (fetchInfo) url; } );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo = lib.mkDefault (
      if config.fetchTree_file.serializerStyle == "string"
      then config.fetchTree_file.serializeFetchInfo_string
      else config.fetchTree_file.serializeFetchInfo_attrs
    );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
      m    = builtins.match "(file\\+)?([^?]+)(\\?([^?]+))?" s;
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
      type = "file";
      url  = path + pnh;
    } // nh' );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            type = lib.mkOption {
              type    = nt.enum ["file"];
              default = "file";
            };
            url     = lib.mkOption { type = nt.str; };
            narHash = lib.mkOption ( {
              type = if fetchers.config.fetchTree_file.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTree_file.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.narHash = let
            locked = fetchers.config.fetchTree_file.lockFetchInfo {
              type = "file";
              inherit (config) url;
            };
          in lib.mkIf ( ! fetchers.config.fetchTree_file.pure ) (
            lib.mkDefault locked.narHash
          );

        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTree_file'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
