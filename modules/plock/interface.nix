# ============================================================================ #
#
# Typed representation of a `package-lock.json(v2/3)' file.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options = {

    plock = lib.mkOption {
      description = ''
        Raw `package-lock.json' contents produced by NPM.
      '';
      type = nt.attrsOf nt.anything;
    };

    lockDir = lib.mkOption {
      description = ''
        Path to the directory containing `package-lock.json'.
        We require this path so that we can fetch source trees declared as
        relative paths in the lockfile.

        NOTE: If your lockfile contains `../*' relative paths it is strongly
        recommended that this option be set to a non-store path.
        If a store path such as `/nix/store/xxxxx-source/../some-dir' is given,
        Nix will crash and burn attempting to fetch `some-dir'.
        A common trick to ensure that you are passing a regular filesystem path
        is to stringize as: `lockDir = toString ./.;'.
      '';
      type    = nt.path;
      example = toString ./my-project;
    };

    plents  = lib.mkOption {
      description = ''
        Translated "package lock entries" ( called `plent's throughout `floco' )
        as attributes remapped from the `package-lock.json:.packages.*' fields.

        NOTE: At this time only `package-lock.json' version 2 and 3 are
        supported because version 1 locks lack a `packages.*' field.
      '';
      type = nt.attrsOf ( import ./types.nix { inherit lib; } ).plent;
    };

    lockfileVersion = lib.mkOption {
      description = ''
        NPM lockfile schema version.

        At this time only version 2 and 3 are supported.
        The beta repository `github:aameen-tulip/at-node-nix' implements support
        for `package-lock.json' v1 which will be migrated at a later date.

        It is strongly recommended that you use version 3 as:
          npm i --package-lock-only --lockfile-version=3 --ignore-scripts;
      '';
      type    = nt.addCheck nt.int ( x: builtins.elem x [2 3] );
      example = 3;
    };

  };  # End `options'

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
