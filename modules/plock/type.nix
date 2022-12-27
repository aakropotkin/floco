# ============================================================================ #
#
# Types associated with individual `package-lock.json:.packages.*' entries.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;
  ft = import ../pdef/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  plent = nt.submodule ( {
    lockDir
  , plentKey
  , plock    ? lib.importJSON "${lockDir}/package-lock.sjon"
  , plentRaw ? plock.packages.${plentKey}
  , ...
  }: {

# ---------------------------------------------------------------------------- #

    freeformType = nt.attrsOf nt.anything;

    options = {

# ---------------------------------------------------------------------------- #

      ident = lib.mkOption {
        description = ''
          Package identifier/name as found in `package.json:.name'.
        '';
        type = ft.ident;
      };

      version = lib.mkOption {
        description = "Package version as found in `package.json:.version'.";
        type        = ft.version;
      };


# ---------------------------------------------------------------------------- #

      dependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };

      requires = lib.mkOption {
        type    = nt.either ( nt.attrsOf nt.str ) nt.bool;
        default = {};
      };

      devDependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };

      dev      = lib.mkOption { type = nt.bool; default = false; };
      optional = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

      os      = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
      cpu     = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
      engines = lib.mkOption { type = nt.attrsOf nt.str; default = {}; };


# ---------------------------------------------------------------------------- #

      resolved = lib.mkOption { type = nt.str; default = "."; };
      link     = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

    };  # End `options'

  } );  # End `plent'

}  # End `types.nix'

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
