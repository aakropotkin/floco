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
      description = lib.mdDoc ''
        Abstract records used to construct instances of common submodule types.

        These base interface must be implemented, but the implementations
        themselves may be swapped or overridden.
      '';
      type = nt.submodule {};
    };

    fetchers = lib.mkOption {
      description = lib.mdDoc ''
        Fetcher abstractions associated with various forms of inputs and
        evaluation rules.
      '';
      type = nt.submodule {};
    };

    builders = lib.mkOption {
      description = lib.mdDoc ''
        Builders used by `floco` to construct derivations.
        These are effectively aliases of `pkgs.*` functions, but they are always
        referred to through this module so that users can swap alternatives.

        In some cases settings related to the builder can be set here to modify
        the behavior of all builds.
      '';
      type = nt.submodule {};
    };

    utils = lib.mkOption {
      description = lib.mdDoc ''
        Utility functions used for misc. tasks suchs as doc generation,
        reading/writing cache files, etc.

        Many of these utilities are used later by `discover` and `plan`
        submodules in `<floco>/stage2.nix`.
      '';
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
