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

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/interface.nix";

# ---------------------------------------------------------------------------- #

  options.fetchers = lib.mkOption {
    type = nt.submodule {

      options.settings = lib.mkOption {
        description = lib.mdDoc ''
          Settings applied to all fetchers or used as fallbacks/defaults for
          options applicable to individual fetchers.
        '';
        type = nt.submodule { freeformType = nt.attrsOf nt.raw; };
      };

      options.tarball = lib.mkOption {
        type = nt.deferredModule;
      };

      options.path = lib.mkOption {
        type = nt.deferredModule;
      };

      options.git = lib.mkOption {
        type = nt.deferredModule;
      };

      options.github = lib.mkOption {
        type = nt.deferredModule;
      };

      options.file = lib.mkOption {
        type = nt.deferredModule;
      };

    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
