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
      engines = lib.mkOption {
        # The fact that this can be a list of strings is fucking infuriating.
        # `{ "node" = ">= 0.8.0"; }' is equivalent to `[ "node >= 0.8.0" ];'.
        # A special circle of hell exists for the NPM devs that approved
        # the schema for `package-lock.json' - they normalize other fields all
        # the time, this makes absolutely no sense.
        type = nt.either ( nt.attrsOf nt.str ) ( nt.listOf nt.str );
        default = {};
      };


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
