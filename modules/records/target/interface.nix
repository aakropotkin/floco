# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/records/target/interface.nix";

  options.target = lib.mkOption {
    description = lib.mdDoc ''
      Abstract record used to declare a package/module build "target".
      A target is analogous to a "lifecycle stage" or "event" which transforms
      a package towards its "prepared" state.

      Targets are designed to run in individual derivations in order to improve
      caching and avoid issues with cyclical dependencies; but users are free
      to optimize their pipelines by combining multiple targets ( an exercise
      for the reader ).

      This is a "deferred" module making it extensible.
      Its base interface must be implemented, but the implementations themselves
      may be swapped or overridden.
    '';
    type = nt.deferredModuleWith {
      staticModules = [
        ( { config, ... }: {

# ---------------------------------------------------------------------------- #

          options.enable  = lib.mkEnableOption "the target";

          options.package = lib.mkOption {
            description = "Derivation which produces the target.";
            type        = nt.package;
          };


# ---------------------------------------------------------------------------- #

          options.scripts = lib.mkOption {
            description = lib.mdDoc ''
              Scripts that should be run during "build" process.
              These scripts are run in the order listed, and if a script is
              undefined in `package.json` it is skipped.
            '';
            type    = nt.listOf nt.str;
            default = [
              "prebuild" "build" "postbuild" "prepublish"
              "preinstall" "install" "postinstall"
            ];
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
              This may resolve issues with certain dependencies with
              non-compliant implementations of `resolve` such as `webpack`
              or `jest`.
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
              These are conventionally libraries, headers, compilers, or
              linkers, and should not be confused with `nativeBuildInputs` which
              are better suited for utilities used only to drive builds
              ( such as `make`, `coreutils`, `grep`, etc ).

              This is processed before overrides, and may be set multiple times
              across modules to create a concatenated list.

              See Also: extraNativeBuildInputs
            '';
            type    = nt.listOf ( nt.either nt.package nt.path );
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

              "Native Build Inputs" are packages/tools that are available at
              build time that are insensitive to
              cross-compilation/linking settings.
              These are conventionally CLI tools such as `make`, `coreutils`,
              `grep`, etc that are required to drive a build, but don't produce
              different outputs depending on the `build`, `host`, or
              `target` platform.

              This is processed before overrides, and may be set multiple times
              across modules to create a concatenated list.
            '';
            type    = nt.listOf ( nt.either nt.package nt.path );
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
              The function is evaluated after `extra*` options, and after
              applying `override` to the orginal argument set.

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

        } )  # End static module
      ];  # End `staticModules'
    };  # End `options.target.type'

    default = {};

  };  # End `options.target'

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
