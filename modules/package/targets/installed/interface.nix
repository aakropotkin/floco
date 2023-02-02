# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/installed/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    installed = lib.mkOption {

# ---------------------------------------------------------------------------- #

      description = lib.mdDoc ''
        "Installed" form of a package/module which is ready consumption as a
        module in a `node_modules/` directory, or global installation for use
        as a package.

        This stage requires that any `install` scripts have been run, which
        conventionally means "run `node-gyp` to perform system dependant
        compilation or setup".

        By default the `prod` tree is used for this stage.

        If no install is required then this option is an alias of `built`.

        XXX: If an `install` script produces executable scripts you should NOT
        patch shebangs yet - patching should be deferred to the
        `prepared` stage.
      '';

      type = nt.submodule {


# ---------------------------------------------------------------------------- #

        options.enable = lib.mkOption {
          description = lib.mdDoc "Whether to enable `installed` target.";
          type        = nt.bool;
          example     = true;
        };


# ---------------------------------------------------------------------------- #

        options.package = lib.mkOption {
          description = lib.mdDoc ''
            Derivation which produces the `installed` form of the
            package/module.
          '';
          type = nt.package;
        };


# ---------------------------------------------------------------------------- #

        options.dependsOnTest = lib.mkOption {
          description = lib.mdDoc ''
            Causes the `installed` lifecycle stage to be blocked by successful
            `test` checking ( requires `test` to be non-null ).

            This is recommended for projects which are under active development.

            If `preferMultipleOutputDerivations` is enabled this is implemented
            by making the `test` derivation an input of the
            `installed` derivation.
            Otherwise this will cause a `preinstall` phase to run `test` checks,
            killing the installer if the check fails.

            NOTE: if `installed` is an alias of `built`, this causes either
            `installed` or `prepared` to depend on `test` instead.

            See Also: lint, built.dependsOnLint
          '';
          type    = nt.bool;
          default = false;
          example = true;
        };


# ---------------------------------------------------------------------------- #

        options.scripts = lib.mkOption {
          description = lib.mdDoc ''
            Scripts that should be run during "install" process.
            These scripts are run in the order listed, and if a script is
            undefined in `package.json` it is skipped.
          '';
          type    = nt.listOf nt.str;
          default = ["preinstall" "install" "postinstall"];
          example = ["install:part1" "install:part2"];
        };


# ---------------------------------------------------------------------------- #

        options.tree = lib.mkOption {
          description = lib.mdDoc ''
            `node_modules/` tree used for installing.
          '';
          type = nt.nullOr nt.package;
        };


        options.copyTree = lib.mkOption {
          description = lib.mdDoc ''
            Whether `node_modules/` tree should be copied into install area
            instead of symlinked.
            This may resolve issues with certain dependencies with non-compliant
            implementations of `resolve` such as `webpack` or `jest`.
          '';
          type    = nt.bool;
          default = false;
          example = true;
        };


# ---------------------------------------------------------------------------- #

        options.extraBuildInputs = lib.mkOption {
          description = lib.mdDoc ''
            Additional `buildInputs` passed to the builder.

            "Build Inputs" are packages/tools that are available at build time
            and respect cross-compilation/linking settings.
            These are conventionally libraries, headers, compilers, or linkers,
            and should not be confused with `nativeBuildInputs` which are
            better suited for utilities used only to drive builds ( such as
            `make`, `coreutils`, `grep`, etc ).

            This is processed before overrides, and may be set multiple times
            across modules to create a concatenated list.

            See Also: extraNativeBuildInputs
          '';
          type    = nt.listOf nt.package;
          default = [];
          example = lib.literalExpression ''
            { pkgs, ... }: {
              config.extraBuildInputs = [pkgs.openssl.dev];
            }
          '';
        };


        options.extraNativeBuildInputs = lib.mkOption {
          description = lib.mdDoc ''
            Additional `nativeBuildInputs` passed to the builder.

            "Native Build Inputs" are packages/tools that are available at build
            time that are insensitive to cross-compilation/linking settings.
            These are conventionally CLI tools such as `make`, `coreutils`,
            `grep`, etc that are required to drive a build, but don't produce
            different outputs depending on the `build`, `host`, or
            `target` platform.

            This is processed before overrides, and may be set multiple times
            across modules to create a concatenated list.
          '';
          type    = nt.listOf nt.package;
          default = [];
          example = lib.literalExpression ''
            { pkgs, ... }: {
              config.extraNativeBuildInputs = [pkgs.typescript];
            }
          '';
        };


# ---------------------------------------------------------------------------- #

        options.override = lib.mkOption {
          description = lib.mdDoc ''
            Overrides applied to `stdenv.mkDerivation` invocation.
            This option is processed after `extra*` options, and
            before `overrideAttrs`.

            See Also: overrideAttrs
          '';
          type    = nt.attrsOf nt.anything;
          default = {};
          example.preBuild = ''
            echo "Howdy" >&2;
          '';
        };


        options.overrideAttrs = lib.mkOption {
          description = lib.mdDoc ''
            Override function applied to `stdenv.mkDerivation` invocation.
            This option is an advanced form of `override` which allows `prev`
            arguments to be referenced.
            The function is evaluated after `extra*` options, and after applying
            `override` to the orginal argument set.

            See Also: override
          '';
          type    = nt.nullOr ( nt.functionTo nt.anything );
          default = null;
          example = lib.literalExpression ''
            { pkgs, config, ... }: {
              config.built.overrideAttrs = prev: {
                # Append pre-release tag to version.
                version = prev.version + "-pre";
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

      };  # End `options.installed.options'

    };  # End `options.installed'

  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
