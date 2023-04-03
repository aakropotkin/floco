# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/sysInfo/interface.nix";

  options.sysInfo = lib.mkOption {
    description = ''
      Indicates platform, arch, and Node.js version support.
    '';

    type = nt.submodule {
      options = {

# ---------------------------------------------------------------------------- #

        os  = lib.libfloco.mkSysOssOption;
        cpu = lib.libfloco.mkSysCpusOption;


# ---------------------------------------------------------------------------- #

        engines = lib.mkOption {
          description = ''
            Indicates supported tooling versions.
          '';
          type = nt.submodule {
            freeformType = nt.attrsOf nt.str;
            options.node = lib.mkOption {
              description = ''
                Supported Node.js versions.
              '';
              type    = nt.str;
              default = "*";
              example = ">=14";
            };
          };
          default.node = "*";
        };


# ---------------------------------------------------------------------------- #

      };  # End `options.sysInfo.type.options'
    };  # End `options.sysInfo.type'

    default = {
      os           = ["*"];
      cpu          = ["*"];
      engines.node = "*";
    };

  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
