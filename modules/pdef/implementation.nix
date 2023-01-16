# ============================================================================ #
#
# A `options.floco.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetchers, ... }: {

# ---------------------------------------------------------------------------- #

  imports = [
    ./binInfo/implementation.nix
    ./depInfo/implementation.nix
    ./treeInfo/implementation.nix
    ./peerInfo/implementation.nix
    ./sysInfo/implementation.nix
    ./fsInfo/implementation.nix
    ./lifecycle/implementation.nix
  ];

  config = {

# ---------------------------------------------------------------------------- #

    ident = let
      fromKey = dirOf config.key;
      fromMF  = config.metaFiles.metaRaw.ident or config.metaFiles.pjs.name;
    in lib.mkDefault ( if config ? key then fromKey else fromMF );

    version = let
      fromKey = baseNameOf config.key;
      fromMF  = config.metaFiles.metaRaw.version or
                config.metaFiles.pjs.version;
    in lib.mkDefault ( if config ? key then fromKey else fromMF );

    key = lib.mkDefault (
      config.metaFiles.metaRaw.key or ( config.ident + "/" + config.version )
    );


# ---------------------------------------------------------------------------- #

    fetchInfo = lib.mkDefault ( {
      type = "tarball";
      url  = let
        bname = baseNameOf config.ident;
        inherit (config) version;
      in "https://registry.npmjs.org/${config.ident}/-/" +
          "${bname}-${version}.tgz";
    } // ( config.metaFiles.metaRaw.fetchInfo or {} ) );


    sourceInfo = let
      type    = config.fetchInfo.type or "path";
      isFT    = type != "path";
      fetcher = if isFT then fetchers."fetchTree_${type}" else fetchers.path;
      fetched = fetcher.function config.fetchInfo;
      src     = if type != "file" then fetched else builtins.fetchTarball {
        url = "file:${builtins.unsafeDiscardStringContext fetched}";
      };
    in lib.mkDefault (
      if isFT && ( type != "file" ) then src else { outPath = src; }
    );


# ---------------------------------------------------------------------------- #

    metaFiles.pjsDir = let
      dp  =
        if ! ( builtins.elem ( config.fsInfo.dir or "." ) ["." "./." "" null] )
        then "/" + config.fsInfo.dir
        else "";
    in lib.mkDefault ( config.sourceInfo.outPath + dp );

    metaFiles.pjs = lib.mkDefault (
      lib.importJSON ( config.metaFiles.pjsDir + "/package.json" )
    );


# ---------------------------------------------------------------------------- #

  # TODO: in order to handle relative paths in a sane way this routine really
  # needs to be outside of the module fixed point, and needs to accept an
  # argument indicating `basedir' to make paths relative from.
  # This works for now but I really don't like it.
  _export = lib.mkMerge [
    {
      inherit (config) ident version ltype;
      fetchInfo =
        if ( config.fetchInfo.type or "path" ) != "path"
        then config.fetchInfo
        else config.fetchInfo // {
          path = builtins.replaceStrings [
            ( toString ( config.metaFiles.lockDir or config.metaFiles.pjsDir ) )
          ] ["."] ( toString config.fetchInfo.path );
        };
    }
    ( lib.mkIf ( config.key != "${config.ident}/${config.version}" ) {
      inherit (config) key;
    } )
  ];


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
