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

  _file = "<floco>/fetchers/fetcher/fetchTarball/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.fetchTarball = lib.mkOption {
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

    };  # End `options.fetchTarball.type'
  };


# ---------------------------------------------------------------------------- #

  config.fetchTarball = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault ( args: let
      swapNar = if ( args.narHash or null ) == null then {} else {
        sha256 = if ( args.sha256 or null ) != null then args.sha256 else
                 args.narHash;
      };
    in builtins.fetchTarball ( ( removeAttrs args ["type"] ) // swapNar ) );


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        sourceInfo = builtins.fetchTree {
          type = "tarball";
          inherit (fetchInfo) url;
        };
        narHash' = if ( fetchInfo.narHash or null ) == null then {
          sha256 = sourceInfo.narHash;
        } else {
          sha256 = fetchInfo.narHash;
        };
        sha256 = if ( fetchInfo.sha256 or null ) != null then {} else narHash';
      in fetchInfo // narHash'
    );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_string = lib.mkDefault ( _file: fetchInfo: let
      pre = let
        m = builtins.match "tarball\\+.*" fetchInfo.url;
      in if m == null then "tarball+" else "";
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
      sha256' = if ( fetchInfo.sha256 or null ) == null then {} else {
        narHash = fetchInfo.sha256;
      };
    in nh' // sha256' // { type = "tarball"; inherit (fetchInfo) url; } );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo = lib.mkDefault (
      if config.fetchTarball.serializerStyle == "string"
      then config.fetchTarball.serializeFetchInfo_string
      else config.fetchTarball.serializeFetchInfo_attrs
    );


# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
      m    = builtins.match "(tarball\\+)?([^?]+)(\\?([^?]+))?" s;
      path = builtins.elemAt m 1;
      prms = builtins.elemAt m 3;
      ps   = if prms == null then [] else
             builtins.filter builtins.isString ( builtins.split "&" prms );
      pp  = builtins.partition ( lib.hasPrefix "narHash=" ) ps;
      nhp = builtins.head pp.right;
      nh' = if ( ( builtins.elemAt m 2 ) == null ) || ( pp.right == [] )
            then {} else {
              sha256 = builtins.head ( builtins.match "narHash=(.*)" nhp );
            };
      pnh = if pp.wrong == [] then "" else
            "?" + ( builtins.concatStringsSep "&" pp.wrong );
    in if builtins.isAttrs s then s else {
      type = "tarball";
      url  = path + pnh;
    } // nh' );


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
              description = lib.mdDoc ''An alias of `sha256`'';
              type = if fetchers.config.fetchTarball.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTarball.pure then {} else {
              default = null;
            } ) );
            sha256 = lib.mkOption ( {
              type = if fetchers.config.fetchTarball.pure then ft.narHash
                     else nt.nullOr ft.narHash;
            } // ( if fetchers.config.fetchTarball.pure then {} else {
              default = null;
            } ) );
          };  # End `fetchInfo.options'

          config.narHash = lib.mkDefault config.sha256;

          config.sha256 = let
            locked = fetchers.config.fetchTarball.lockFetchInfo {
              inherit (config) url;
            };
          in lib.mkIf ( ! fetchers.config.fetchTarball.pure ) (
            lib.mkDefault locked.sha256
          );

        } )
      ];
    };  # End `fetchInfo'


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTarball'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
