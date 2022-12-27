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

  plent = nt.submodule {

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

      key = lib.mkOption {
        description = ''
          Unique key used to refer to this package in `tree' submodules and
          other `floco' configs, metadata, and structures.
        '';
        type = ft.key;
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
      # In the lockfile this can also be a list of strings as:
      #   ["node >= 8.0.0"]
      # Which is fucking infuriating but whatever.
      # We normalize it in our implementation.
      engines = lib.mkOption { type = nt.attrsOf nt.str; default = {}; };


# ---------------------------------------------------------------------------- #

      resolved = lib.mkOption { type = nt.str; default = "."; };
      link     = lib.mkOption { type = nt.bool; default = false; };

# ---------------------------------------------------------------------------- #

      hasInstallScript = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

    };  # End `options'

  };  # End `plent'

}  # End `types.nix'

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
