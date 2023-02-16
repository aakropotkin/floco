# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, options
, specialArgs
, ...
}: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/stage1.nix";

  imports = [
    ./stage0.nix
    ./records
    ./fetchers
    ./builders
    ./utils
  ];

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    # Stage 1

    records = lib.mkOption {
      type = nt.submodule {};
    };

    fetchers = lib.mkOption {
      type = nt.submodule {};
    };

    builders = lib.mkOption {
      type = nt.submodule {};
    };

    utils = lib.mkOption {
      type = nt.submodule {};
    };


# ---------------------------------------------------------------------------- #

  };


# ---------------------------------------------------------------------------- #

  config.env    = lib.mkForce specialArgs.env;
  config.inputs = lib.mkForce specialArgs.inputs;

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
