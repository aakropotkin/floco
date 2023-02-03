# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/settings/interface.nix";

  options.settings = lib.mkOption {
    description = lib.mdDoc ''
      Global settings used by various submodules.
      These are organized at the top level for the convenience of the user.
    '';
    type = nt.submodule {

# ---------------------------------------------------------------------------- #

      options.basedir = lib.mkOption {
        description = lib.mdDoc ''
          Directory used to form relative paths when serializing `fetchInfo`
          records to a file.
        '';
        type    = nt.nullOr nt.path;
        default = null;
      };


# ---------------------------------------------------------------------------- #

      options.system = lib.mkOption {
        description = lib.mdDoc ''
          System pair used as `build` and `host` platform.
        '';
        type = nt.enum [
          "x86_64-linux"  "x86_64-darwin"
          "aarch64-linux" "aarch64-darwin"
          "i686-linux"
          "unknown"
        ];
        example = "x86_64-linux";
      };


# ---------------------------------------------------------------------------- #

    };  # End `options.settings.type'
    default = {};
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
