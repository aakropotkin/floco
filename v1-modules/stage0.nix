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

  _file = "<floco>/stage0.nix";

  imports = [
    ./inputs
    ./env
  ];


# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    settings = lib.mkOption {
      description = lib.mdDoc ''
        Global settings used to configure floco.

        Often this submodule is used to fill defaults for other submodules in
        later stages.
      '';
      type = nt.submodule { freeformType = nt.attrsOf nt.raw; };
    };

    inputs = lib.mkOption {
      description = lib.mdDoc ''
        Attrset of `flake` style inputs.

        These records carry a `flake`, `tree`, and `uri` field which can be used
        to use these inputs in legacy commands.
      '';
      visible = "shallow";
    };

    env = lib.mkOption {
      description = lib.mdDoc ''
        Prepares `pkgs`, `lib`, and similar Nixpkgs' style attrsets
        to be used by later stages of `floco` evaluation.

        This ensures the availability of necessary derivations and routines.
      '';
      type = nt.submodule {};
    };


# ---------------------------------------------------------------------------- #

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
