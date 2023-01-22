# ============================================================================ #
#
# Typed representation of a `yarn.lock(v5)' file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/ylock/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

    ylock = lib.mkOption {
      description = lib.mdDoc ''
        Raw `yarn.lock` contents produced by `yarn`.
      '';
      type = nt.attrsOf nt.anything;
    };

    lockDir = lib.mkOption {
      description = lib.mdDoc ''
        Path to the directory containing `yarn.lock`.
        We require this path so that we can fetch source trees declared as
        relative paths in the lockfile.

        NOTE: If your lockfile contains `../*` relative paths it is strongly
        recommended that this option be set to a non-store path.
        If a store path such as `/nix/store/xxxxx-source/../some-dir` is given,
        Nix will crash and burn attempting to fetch `some-dir`.
        A common trick to ensure that you are passing a regular filesystem path
        is to stringize as: `lockDir = toString ./.;`.
      '';
      type    = nt.path;
      example = toString ./my-project;
    };

    ylents = lib.mkOption {
      description = lib.mdDoc ''
        Translated "yarn lock entries" ( called `ylent's throughout `floco' ).
        This excludes the `__metadata` entry.
      '';
      type = nt.attrsOf ( import ./types.nix { inherit lib; } ).ylent;
    };

    # Pulled from `__metadata.version' field.
    lockfileVersion = lib.mkOption {
      description = lib.mdDoc ''
        `yarn` lockfile schema version.

        At this time only version 5 is supported.
      '';
      type    = nt.addCheck nt.int ( x: builtins.elem x [5] );
      example = 5;
    };

  };  # End `options'

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
