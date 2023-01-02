# ============================================================================ #
#
# A `options.flocoPackages.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

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

    fetchInfo = let
      # Locks `fetchInfo'
      fii = import ../fetchInfo/implementations.nix { inherit lib; };
      unlocked = {
        type = "tarball";
        url  = let
          bname = baseNameOf config.ident;
          inherit (config) version;
        in "https://registry.npmjs.org/${config.ident}/-/" +
           "${bname}-${version}.tgz";
      } // ( config.metaFiles.metaRaw.fetchInfo or {} );
    in lib.mkDefault ( fii.fetchTree.tarball { config = unlocked; } );


    sourceInfo = let
      # We wrap `builtins.path' to make paths absolute.
      # TODO: use a `specialArgs.basedir' or find some way to access the
      # declarations' `file' information so that this is less fucky.
      # Honestly I really don't like relying on `metaFiles.*' being defined to
      # handle this.
      pathW = { path, ... } @ args: let
        args' = if lib.hasPrefix "/" ( toString path ) then args else args // {
          name = args.name or "source";
          path =
            ( toString ( config.metaFiles.lockDir or config.metaFiles.pjsDir ) )
            + "/" + path;
        };
      in builtins.path args';
      isFT    = ( config.fetchInfo.type or null ) != null;
      isFile  = ( config.fetchInfo.type or null ) == "file";
      fetcher = if isFT then builtins.fetchTree else pathW;
      src     = if isFile then builtins.fetchTarball {
        url = "file:${
          builtins.unsafeDiscardStringContext ( fetcher config.fetchInfo )
        }";
      } else fetcher config.fetchInfo;
    in lib.mkDefault (
      if isFT && ( ! isFile ) then src else { outPath = src; }
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
          ] ["."] config.fetchInfo.path;
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
