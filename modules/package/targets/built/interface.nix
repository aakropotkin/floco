# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    built = lib.mkOption {

# ---------------------------------------------------------------------------- #

      description = lib.mdDoc ''
        "Built" form of a package/module which is ready for distribution as a
        tarball ( `build` and `prepublish` scripts must be run if defined ).

        By default the `dev` tree is used for this stage.

        If no build is required then this option is an alias of `source`.

        XXX: If a `build` script produces executable scripts you should NOT
        patch shebangs yet - patching should be deferred to the
        `prepared` stage.
      '';

      type = nt.submodule {

# ---------------------------------------------------------------------------- #

        options.enable = lib.mkOption {
          description = lib.mdDoc "Whether to enable `built` target.";
          type        = nt.bool;
          example     = true;
        };


# ---------------------------------------------------------------------------- #

        options.package = lib.mkOption {
          description = lib.mdDoc ''
            Derivation which produces the `built` form of the package/module.
          '';
          type = nt.package;
        };


# ---------------------------------------------------------------------------- #

        options.dependsOnLint = lib.mkOption {
          description = lib.mdDoc ''
            Causes the `built` lifecycle stage to be blocked by successful
            `lint` checking ( requires `lint` to be non-null ).

            This is recommended for projects which are under active development.

            If `preferMultipleOutputDerivations` is enabled this is implemented
            by making the `lint` derivation an input of the `built` derivation.
            Otherwise this will cause a `preBuild` phase to run `lint` checks,
            killing the builder if the check fails.

            NOTE: if `built` is an alias of `source`, this causes either
            `installed` or `prepared` to depend on `lint` instead.

            See Also: lint, install.dependsOnTest
          '';
          type    = nt.bool;
          default = false;
          example = true;
        };


# ---------------------------------------------------------------------------- #

        options.scripts = lib.mkOption {
          description = lib.mdDoc ''
            Scripts that should be run during "build" process.
            These scripts are run in the order listed, and if a script is
            undefined in `package.json` it is skipped.
          '';
          type    = nt.listOf nt.str;
          default = ["prebuild" "build" "postbuild" "prepublish"];
          example = ["build:part1" "build:part2"];
        };


# ---------------------------------------------------------------------------- #

        options.tree = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` tree used for building.
          '';
          type = nt.nullOr nt.package;
        };


        options.copyTree = lib.mkOption {
          description = lib.mdDoc ''
            Whether `node_modules/` tree should be copied into build area
            instead of symlinked.
            This may resolve issues with certain dependencies with non-compliant
            implementations of `resolve` such as `webpack` or `jest`.
          '';
          type    = nt.bool;
          default = false;
          example = true;
        };


# ---------------------------------------------------------------------------- #

        options.override = lib.mkOption {
          description = lib.mdDoc ''
            Overrides applied to `stdenv.mkDerivation` invocation.
            This option is a shorthand form of `overrideAttrs` and it is an
            error to set both options.

            See Also: *.overrideAttrs
          '';
          type    = nt.nullOr ( nt.attrsOf nt.anything );
          default = null;
          example.preBuild = ''
            echo "Howdy" >&2;
          '';
        };


        options.overrideAttrs = lib.mkOption {
          description = lib.mdDoc ''
            Override function applied to `stdenv.mkDerivation` invocation.
            This option is an advanced form of `override` which allows `prev`
            arguments to be referenced.
            It is an error to set both options.

            See Also: *.override
          '';
          type    = nt.nullOr ( nt.functionTo nt.anything );
          default = null;
          example = lib.literalExpression ''
            { pkgs, config, ... }: {
              config.built.overrideAttrs = prev: {
                nativeBuildInputs = prev.nativeBuildInputs ++ [
                  pkgs.typescript
                ];
              };
            }
          '';
        };


# ---------------------------------------------------------------------------- #

        options.warnings = lib.mkOption {
          description = ''
            List of warnings to be emitted when derivation is evaluated.
          '';
          type     = nt.listOf nt.str;
          default  = [];
          internal = true;
          visible  = false;
        };


# ---------------------------------------------------------------------------- #

      };  # End `options.built.options'

    };  # End `options.built'

  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
