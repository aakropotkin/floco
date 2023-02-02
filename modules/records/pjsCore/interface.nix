# ============================================================================ #
#
# Core fields found on `package.json' style metadata records.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/records/pjsCore/interface.nix";

  options.pjsCore = lib.mkOption {
    type = nt.deferredModuleWith {
      staticModules = [
        ( { config, ... }: {
          imports = [( lib.mkAliasOptionModule ["name"] ["ident"] )];
          options = {
            key     = lib.mkKeyOption;
            ident   = lib.mkIdentOption;
            version = lib.mkVersionOption;

            dependencies         = lib.mkDepAttrsOption;
            devDependencies      = lib.mkDepAttrsOption;
            devDependenciesMeta  = lib.mkDepMetasOption;
            peerDependencies     = lib.mkDepAttrsOption;
            peerDependenciesMeta = lib.mkDepMetasOption;
            optionalDependencies = lib.mkDepAttrsOption;

            os  = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
            cpu = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };

            engines = lib.mkOption {
              type    = nt.attrsOf nt.str;
              default = {};
              example.node = ">=8.0.0";
            };
          };
          config.key = lib.mkDefault ( config.ident + "/" + config.version );
        } )
      ];
    };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
