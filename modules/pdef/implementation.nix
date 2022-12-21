# ============================================================================ #
#
# A `options.flocoPackages.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

  config = {
    ident           = lib.mkDefault ( dirOf config.key );
    version         = lib.mkDefault ( baseNameOf config.key );
    key             = lib.mkDefault ( config.ident + "/" + config.version );

    lifecycle.build = lib.mkDefault ( config.ltype != "file" );

    fetchInfo = lib.mkDefault {
      type = "tarball";
      url  = let
        bname = baseNameOf config.ident;
        inherit (config) version;
      in "https://registry.npmjs.org/${config.ident}/-/${bname}-${version}.tgz";
    };

    sourceInfo = let
      isFT    = ( config.fetchInfo.type or null ) != null;
      isFile  = ( config.fetchInfo.type or null ) == "file";
      fetcher = if isFT then builtins.fetchTree else builtins.path;
      src     = if isFile then builtins.fetchTarball {
        url = "file:${
          builtins.unsafeDiscardStringContext ( fetcher config.fetchInfo )
        }";
     } else fetcher config.fetchInfo;
    in if isFT && ( ! isFile ) then src else { outPath = src; };

    metaFiles.pjsDir = let
      dp  =
        if ! ( builtins.elem ( config.fsInfo.dir or "." ) ["." "./." "" null] )
        then "/" + config.fsInfo.dir
        else "";
    in lib.mkDefault ( config.sourceInfo.outPath + dp );

    metaFiles.pjs =
      lib.importJSON ( config.metaFiles.pjsDir + "/package.json" );
    metaFiles.packumentUrl = "https://registry.npmjs.org/${config.ident}";
    metaFiles.vinfoUrl     =
      "https://registry.npmjs.org/${config.ident}/${config.version}";
  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
