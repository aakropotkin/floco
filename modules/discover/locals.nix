# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  project = { config, options, ... }: {

    options.ident   = lib.mkIdentOption;
    options.version = lib.mkIdentOption;
    options.key     = lib.mkKeyOption;
    options.dir     = lib.mkOption { type = nt.path; };

    options.metaFiles = lib.mkOption {
      type = nt.submodule {
        options.allowPjs   = lib.mkEnableOption "processing package.json";
        options.allowPlock = lib.mkEnableOption "processing package-lock.json";
        options.allowYlock = lib.mkEnableOption "processing yarn.lock";
        options.allowPdefs = lib.mkEnableOption "processing pdefs.{nix,json}";

        options.allowFlocoCfg =
          lib.mkEnableOption "processing floco-cfg.{nix,json}";

        options.pjs      = lib.mkOption { type = nt.raw; };
        options.plock    = lib.mkOption { type = nt.raw; };
        options.ylock    = lib.mkOption { type = nt.raw; };
        options.pdefs    = lib.mkOption { type = nt.raw; };
        options.flocoCfg = lib.mkOption { type = nt.raw; };
      };
    };

    options.flocoModules = lib.mkOption {
      type    = nt.listOf nt.deferredModule;
      default = [];
    };

    config.metaFiles = let
      pdefsFile =
        if builtins.pathExists ( config.dir + "/pdefs.nix" ) then
          config.dir + "/pdefs.nix"
        else if builtins.pathExists ( config.dir + "/pdefs.json" ) then
          config.dir + "/pdefs.json"
        else null;
      flocoCfgFile =
        if builtins.pathExists ( config.dir + "/floco-cfg.nix" ) then
          config.dir + "/floco-cfg.nix"
        else if builtins.pathExists ( config.dir + "/floco-cfg.json" ) then
          config.dir + "/floco-cfg.json"
        else null;
    in {
      allowPjs = lib.mkDefault (
        builtins.pathExists ( config.dir + "/package.json" )
      );
      allowPlock = lib.mkDefault (
        builtins.pathExists ( config.dir + "/package-lock.json" )
      );
      allowYlock = lib.mkDefault (
        builtins.pathExists ( config.dir + "/yarn.lock" )
      );
      allowPdefs    = lib.mkDefault ( pdefsFile != null );
      allowFlocoCfg = lib.mkDefault ( flocoCfgFile != null );

      pjs = lib.mkDefault (
        if ! config.metaFiles.allowPjs then null else
        lib.importJSON ( config.dir + "/package.json" )
      );
      plock = lib.mkDefault (
        if ! config.metaFiles.allowPlock then null else
        lib.importJSON ( config.dir + "/package-lock.json" )
      );
      # TODO: parse yarn.lock
      ylock = lib.mkDefault (
        if ! config.metaFiles.allowYlock then null else
        builtins.readFile ( config.dir + "/yarn.lock" )
      );
      pdefs = lib.mkDefault (
        if ! config.metaFiles.allowPdefs then null else
        if lib.hasSuffix ".nix" pdefsFile then {
          _file  = pdefsFile;
          config = import pdefsFile;
        } else lib.modules.importJSON pdefsFile
      );
      flocoCfg = lib.mkDefault (
        if ! config.metaFiles.allowFlocoCfg then null else
        if lib.hasSuffix ".nix" flocoCfgFile then {
          _file  = flocoCfgFile;
          config = import flocoCfgFile;
        } else lib.modules.importJSON flocoCfgFile
      );

    };  # End `config.metaFiles'

    config.flocoModules = lib.mkDerivedConfig options.metaFiles ( metaFiles:
      builtins.filter builtins.isAttrs [metaFiles.pdefs metaFiles.flocoCfg]
    );

    config.ident = lib.mkDerivedConfig options.metaFiles ( metaFiles:
      metaFiles.pjs.name or metaFiles.plock.name or ( baseNameOf config.dir )
    );

    config.version = lib.mkDerivedConfig options.metaFiles ( metaFiles:
      metaFiles.pjs.version or metaFiles.plock.version or "0.0.0-0"
    );

    config.key = lib.mkDefault ( config.ident + "/" + config.version );

  };  # End `project'


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/discover/locals.nix";

# ---------------------------------------------------------------------------- #

  options.discover = lib.mkOption {
    type = nt.submodule {
      options.locals = lib.mkOption {
        description = lib.mdDoc ''
          Discovers and resolves local packages, organizing them for processing
          by translators and other tools.
        '';
        type = nt.submodule ( { config, options, ... }: {

          options.dirs = lib.mkOption {
            type        = nt.listOf nt.path;
            default     = [];
            description = "List of directories to search for local packages.";
          };

          options.packages = lib.mkOption {
            type        = nt.attrsOf ( nt.submodule project );
            description = "Collection of local packages' discovery info.";
          };

          config.packages = let
            def = dir: {
              name  = baseNameOf dir;
              value = { inherit dir; };
            };
          in builtins.listToAttrs ( map def config.dirs );

        } );
      };
    };
  };  # End `options.discover'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
