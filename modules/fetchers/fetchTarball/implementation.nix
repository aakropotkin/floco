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

      options.serializerHashKey = lib.mkOption {
        description = lib.mdDoc ''
          Attribute or query parameter name used to refer to `narHash`/`sha256`
          when serializing a `fetchInfo` record.

          This option allows you to control which name is written to lockfiles
          which may be useful for interop with other `tarball` fetchers.
        '';
        type    = nt.enum ["narHash" "sha256"];
        default = "narHash";
        example = "sha256";
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
      args' = ( removeAttrs args ["type" "narHash"] ) // swapNar;
    in { outPath = builtins.fetchTarball args'; } );


# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
      sourceInfo = builtins.fetchTree {
        type = "path";
        path = ( config.fetchTarball.function fetchInfo ).outPath;
      };
      hash = let
        s = fetchInfo.sha256 or null;
        n = fetchInfo.narHash or null;
      in if s != null then s else if n != null then n else sourceInfo.narHash;
    in fetchInfo // { sha256 = hash; } );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_string = lib.mkDefault ( _file: fetchInfo: let
      hash = let
        s = fetchInfo.sha256 or null;
        n = fetchInfo.narHash or null;
      in if s == null then n else s;
      key  = config.fetchTarball.serializerHashKey;
      pre  = let
        m = builtins.match "tarball\\+.*" fetchInfo.url;
      in if m == null then "tarball+" else "";
      psep =
        if ( builtins.match ".*\\?.*" fetchInfo.url ) == null then "?" else "&";
      mh = builtins.match "[^?]+\\?([^?]+&)?(narHash|sha256)=[^&]+(&[^?]+)?"
                          fetchInfo.url;
      k  = builtins.elemAt mh 1;
      post = if ( mh != null ) || ( hash == null ) then "" else
             psep + key + "=" + fetchInfo.narHash;
      base = pre + fetchInfo.url + post;
      sub  = let
        nkey = if key == "narHash" then "sha256=" else "narHash=";
      in builtins.replaceStrings [nkey] [( key + "=" )] base;
    in if ( mh == null ) || ( k == key ) then base else sub );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_attrs = lib.mkDefault ( _file: fetchInfo: let
      hash = let
        s = fetchInfo.sha256 or null;
        n = fetchInfo.narHash or null;
      in if s == null then n else s;
      hash' = if hash == null then {} else {
        ${config.fetchTarball.serializerHashKey} = hash;
      };
    in hash' // { type = "tarball"; inherit (fetchInfo) url; } );


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
      pp = let
        pred = s: ( builtins.match "(narHash|sha256)=.*" s ) != null;
      in builtins.partition pred ps;
      nhp = builtins.head pp.right;
      hash' = let
        hash = builtins.elemAt ( builtins.match "(narHash|sha256)=(.*)" nhp ) 1;
        noParams = ( builtins.elemAt m 2 ) == null;
      in if noParams || ( pp.right == [] ) then {} else { sha256 = hash; };
      pnh = if pp.wrong == [] then "" else
            "?" + ( builtins.concatStringsSep "&" pp.wrong );
    in if builtins.isAttrs s then s else {
      type = "tarball";
      url  = path + pnh;
    } // hash' );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          imports = [( lib.mkAliasOptionModule ["sha256"] ["narHash"] )];
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
          };  # End `fetchInfo.options'

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
