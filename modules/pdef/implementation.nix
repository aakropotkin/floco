# ============================================================================ #
#
# A `options.flocoPackages.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... } @ args: {

# ---------------------------------------------------------------------------- #

  imports =
    ( if args.specialArgs.packument.enable or false then [
        ./packument.implementation.nix
      ] else [] ) ++
    ( if args.specialArgs.vinfo.enable or false then [
        ./vinfo.implementation.nix
      ] else [] );


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

    lifecycle.build = let
      fromLtype   = config.ltype != "file";
      fromScripts = let
        s = config.metaFiles.metaRaw.scripts or config.metaFiles.pjs.scripts or
            {};
      in if ! ( config ? metaFiles.pjs ) then true else
         ( s ? prebuild ) || ( s ? build ) || ( s ? postbuild ) ||
         ( s ? prepublish );
    in lib.mkDefault (
      config.metaFiles.metaRaw.lifecycle.build or ( fromLtype && fromScripts )
    );

    lifecycle.install = let
      fromScripts = let
        s = config.metaFiles.metaRaw.scripts or config.metaFiles.pjs.scripts or
            {};
      in ( s ? preinstall ) || ( s ? install ) || ( s ? postinstall );
      gypfile = config.metaFiles.metaRaw.gypfile or
                config.metaFiles.pjs.gypfile or
                config.fsInfo.gypfile;
    in lib.mkDefault (
      config.metaFiles.metaRaw.lifecycle.install or
      config.metaFiles.plent.hasInstallScript or ( fromScripts || gypfile )
    );


# ---------------------------------------------------------------------------- #

    binInfo = let
      bin = config.metaFiles.metaRaw.bin or (
        if config.metaFiles ? plent then config.metaFiles.plent.bin or {} else
        if config.metaFiles ? pjs then config.metaFiles.pjs.bin or {} else
        null
      );
      binDir = if bin != null then null else
        config.metaFiles.metaRaw.binDir or
        config.metaFiles.metaRaw.directories.bin or
        config.metaFiles.pjs.directories.bin or null;
    in lib.mkDefault ( config.metaFiles.metaRaw.binInfo or {
      inherit binDir;
      binPairs = if bin == null then null else
                 if builtins.isAttrs bin then bin else
                 { ${baseNameOf config.ident} = bin; };
    } );


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


    fsInfo = lib.mkDefault ( config.metaFiles.metaRaw.fsInfo or {
      gypfile =
        builtins.pathExists ( config.metaFiles.pjsDir + "/binding.gyp" );
    } );


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
  _export  = {
    inherit (config)
      ident version key ltype depInfo peerInfo binInfo fsInfo lifecycle sysInfo
    ;
    fetchInfo =
      if ( config.fetchInfo.type or "path" ) != "path"
      then config.fetchInfo
      else config.fetchInfo // {
        path = builtins.replaceStrings [
          ( toString ( config.metaFiles.lockDir or config.metaFiles.pjsDir ) )
        ] ["."] config.fetchInfo.path;
      };
  } // ( if config ? treeInfo then { inherit (config) treeInfo; } else {} );


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
