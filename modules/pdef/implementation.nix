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

    depInfo = let
      getDfs = builtins.intersectAttrs {
        requires             = true;
        dependencies         = true;
        devDependencies      = true;
        peerDependencies     = true;
        devDependenciesMeta  = true;
        peerDependenciesMeta = true;
        optionalDependencies = true;
        bundleDependencies   = true;
        bundledDependencies  = true;
      };
    in lib.mkDefault ( import ./depinfo.implementation.nix {
      inherit lib;
      config =
        builtins.foldl' ( acc: f:
          if config.metaFiles.${f} == null then acc else
          acc // ( getDfs config.metaFiles.${f} )
        ) {} ["plent" "pjs" "metaRaw"];
    } );


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

    metaFiles.packumentUrl = lib.mkDefault (
      if config.ltype != "file" then null else
      "https://registry.npmjs.org/${config.ident}"
    );

    metaFiles.packumentHash = lib.mkDefault (
      if config.metaFiles.packumentUrl == null then null else
      ( builtins.fetchTree {
        type = "file";
        url  = config.metaFiles.packumentUrl;
      } ).narHash
    );

    metaFiles.packument = let
      fetched = builtins.fetchTree {
        type    = "file";
        url     = config.metaFiles.packumentUrl;
        narHash = config.metaFiles.packumentHash;
      };
      attrs = lib.importJSON fetched;
    in lib.mkDefault (
      if config.metaFiles.packumentUrl != null then attrs else null
    );

    metaFiles.packumentRev =
      if config.metaFiles.packument == null then null else
      config.metaFiles.packument._rev;


# ---------------------------------------------------------------------------- #

    metaFiles.vinfoUrl = lib.mkDefault (
      if config.ltype != "file" then null else
      "https://registry.npmjs.org/${config.ident}/${config.version}"
    );

    metaFiles.vinfoHash = lib.mkDefault (
      if config.metaFiles.vinfoUrl == null then null else
      ( builtins.fetchTree {
        type = "file";
        url  = config.metaFiles.vinfoUrl;
      } ).narHash
    );

    metaFiles.vinfo = let
      fetched = builtins.fetchTree {
        type    = "file";
        url     = config.metaFiles.vinfoUrl;
        narHash = config.metaFiles.vinfoHash;
      };
      attrs = lib.importJSON fetched;
    in lib.mkDefault (
      if config.metaFiles.vinfoUrl != null then attrs else null
    );


# ---------------------------------------------------------------------------- #

  _export  = {
    inherit (config)
      ident version key ltype depInfo binInfo fsInfo lifecycle sysInfo
    ;
    metaFiles = builtins.intersectAttrs {
      vinfoUrl      = true;
      vinfoHash     = true;
      packumentUrl  = true;
      packumentHash = true;
      packumentRev  = true;
    } config.metaFiles;
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
