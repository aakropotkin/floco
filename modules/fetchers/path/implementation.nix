# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = lib.libfloco;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/path/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.path = lib.mkOption {
    type = nt.submodule { imports = [fetcher]; };
  };


# ---------------------------------------------------------------------------- #

  config.path = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault ( args: let
        args' = if ( args.sha256 or null ) != null then args else
                removeAttrs args ["sha256"];
      in { outPath = builtins.path args'; }
    );

# ---------------------------------------------------------------------------- #

    lockFetchInfo = lib.mkDefault ( fetchInfo: let
        inherit (config.path.function {
          inherit (fetchInfo) name path filter recursive;
        }) outPath;
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
        serializable = removeAttrs fetchInfo ["filter" "sha256"];
      in lib.moduleDropDefaults config.path.fetchInfo serializable;
      #sha256 = if fetchInfo.sha256 != null then fetchInfo.sha256 else
      #         ( config.path.lockFetchInfo fetchInfo ).sha256;
      fp = if builtins.isPath _file then toString _file else
           builtins.unsafeDiscardStringContext _file;
      rp = if builtins.pathExists ( fp + "/." ) then /. + fp else
           /. + ( dirOf fp );
      path     = lib.realpathRel rp fetchInfo.path;
      isSimple = ( builtins.attrNames keeps ) == ["path"];
    in if isSimple then "path:" + path else keeps // { inherit path; } );

# ---------------------------------------------------------------------------- #

    deserializeFetchInfo = lib.mkDefault ( _file: s: let
      fp = if builtins.isPath _file then toString _file else
           builtins.unsafeDiscardStringContext _file;
      rp = if builtins.pathExists ( fp + "/." ) then /. + fp else
           /. + ( dirOf fp );
      p  = if builtins.isAttrs s then s.path else
           if builtins.isPath s then s else
           lib.removePrefix "path:" s;
      path'  = if lib.isAbspath p then p else rp + ( "/" + p );
      attrs' = if builtins.isAttrs s then s else {};
    in attrs' // {
      path = if builtins.isPath path' then path' else /. + path';
    } );


# ---------------------------------------------------------------------------- #

    fetchInfo = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { config, ... }: {
          options = {
            name   = lib.mkOption { type = nt.str; default = "source"; };
            path = lib.mkOption {
              type = ( nt.either nt.path nt.str ) // {
                merge = lib.mergeRelativePathOption;
              };
            };
            filter = lib.mkOption {
              type    = nt.functionTo ( nt.functionTo nt.bool );
              default = name: type: true;
            };
            recursive = lib.mkOption { type = nt.bool; default = true; };
            sha256    = lib.mkOption {
              type = let
                base = nt.either ft.sha256_hash ft.sha256_sri;
              in nt.nullOr base;
              default = null;
            };
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

    input = lib.mkDefault ( nt.strMatching "path:\\..*" );


# ---------------------------------------------------------------------------- #

  };  # End `config.path'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
