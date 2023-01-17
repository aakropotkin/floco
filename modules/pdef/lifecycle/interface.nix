# ============================================================================ #
#
# Controls the execution of lifecycle events.
# When set to `true' preparation of a module will run a given event first.
#
# Some events like `test', `lint', and `dist' only block preparation when
# certain `floco.packages.<IDENT>.<VESION>.*' settings explicitly
# request them to.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdef/lifecycle/interface.nix";

# ---------------------------------------------------------------------------- #

  options.lifecycle = lib.mkOption {

    description = ''
      Enables/disables phases executed when preparing a package/module for
      consumption or installation.

      Executing a phase when no associated script is defined is not
      necessarily harmful, but has a drastic impact on performance and may
      cause infinite recursion if dependency cycles exist among packages.

      See Also: ltype
    '';

    type = nt.submodule {
      freeformType = nt.attrsOf nt.bool;
      options = {
        build = lib.mkOption {
          description = ''
            Whether a package or module requires build scripts to be run before
            it is prepared for consumption.

            This field should never be set to true when consuming registry
            tarballs even if they define build scripts, since they are
            distributed after being built by authors and maintainers.
          '';
          type    = nt.bool;
          default = false;
        };

        install = lib.mkOption {
          description = lib.mdDoc ''
            Whether a package or module requires `[pre|post]install` scripts or
            `node-gyp` compilation to be performed before a distributed tarball
            is prepared for consumption.
          '';
          type    = nt.bool;
          default = false;
        };
      };  # End `lifecycle.type.options'
    };  # End `lifecycle.type'

    default = { build = false; install = false; };

  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
