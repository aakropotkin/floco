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

        os = lib.mkOption {
          description = lib.mdDoc ''
            List of supported operating systems.
            The string `"*"` indicates that all operating systems
            are supported.
          '';
          type = lib.libfloco.uniqueListOf ( nt.enum [
            "*" "darwin" "freebsd" "netbsd" "linux" "openbsd" "sunprocess"
            "win32" "unknown"
          ] );
          default = ["*"];
        };


# ---------------------------------------------------------------------------- #

        cpu = lib.mkOption {
          description = lib.mdDoc ''
            List of supported CPU architectures.
            The string `"*"` indicates that all CPUs are supported.
          '';
          type = lib.libfloco.uniqueListOf ( nt.enum [
            "*" "x86_64" "i686" "aarch" "aarch64" "powerpc64le" "mipsel"
            "riscv64" "unknown"
          ] );
          default = ["*"];
        };


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
