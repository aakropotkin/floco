# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, ...
}: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<libfloco>/types/pjsCore/submodule.nix";

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
    bundledDependencies  = lib.mkOption {
      type    = nt.either nt.bool ( nt.listOf nt.str );
      default = [];
    };

    os  = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
    cpu = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };

    engines = lib.mkOption {
      type    = nt.attrsOf nt.str;
      default = {};
      example.node = ">=8.0.0";
    };

    bin = lib.mkPjsBinOption // {
      type = nt.coercedTo nt.str
                          ( p: { ${baseNameOf config.ident} = p; } )
                          lib.libfloco.binPairs;
    };

  };

  config.key = lib.mkDefault ( config.ident + "/" + config.version );


}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
