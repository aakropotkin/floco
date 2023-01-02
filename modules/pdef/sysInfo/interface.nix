# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.sysInfo = lib.mkOption {
    description = ''
      Indicates platform, arch, and Node.js version support.
    '';
    type = nt.submodule {
      options = {
        os = lib.mkOption {
          description = lib.mdDoc ''
            List of supported operating systems.
            The string `"*"` indicates that all operating systems
            are supported.
          '';
          type    = nt.listOf nt.str;
          default = ["*"];
        };

        cpu = lib.mkOption {
          description = lib.mdDoc ''
            List of supported CPU architectures.
            The string `"*"` indicates that all CPUs are supported.
          '';
          type    = nt.listOf nt.str;
          default = ["*"];
        };

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
      };
    };

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
