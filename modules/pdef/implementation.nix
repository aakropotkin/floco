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
    metaFiles.pjsDir = let
      fetcher =
        if ( config.fetchInfo.type or null ) == null then builtins.path else
        builtins.fetchTree;
      src = fetcher config.fetchInfo;
      dp  =
        if ! ( builtins.elem ( config.fsInfo.dir or "." ) ["." "./." "" null] )
        then "/" + config.fsInfo.dir
        else "";
    in lib.mkDefault ( src.outPath + dp );
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
