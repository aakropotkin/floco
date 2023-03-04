# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  depInfoBaseEntryDeferred = {

    _file = "<libfloco>/types/depInfo/base.nix:depInfoBaseEntryDeferred";

    # Additional bool fields may be added in association with various lifecycle
    # events such as `test', `lint', etc allowing users to minimize the trees
    # used for those events.
    freeformType = nt.attrsOf nt.bool;

    options = {

      descriptor = lib.libfloco.mkDescriptorOption;
      pin        = lib.libfloco.mkPinOption;

      optional = lib.mkOption {
        description =  lib.mdDoc ''
          Whether the dependency may be omitted from the `node_modules/` tree
          during post-distribution phases.

          Conventionally this is used to mark dependencies which are only
          required under certain conditions such as platform, architecture,
          or engines.
          Generally optional dependencies carry `sysInfo` conditionals, or
          `postinstall` scripts which must be allowed to fail without blocking
          the build of the consumer.
        '';
        type    = nt.bool;
        default = false;
      };

      bundled = lib.mkOption {
        description = lib.mdDoc ''
          Whether the dependency is distributed in registry tarballs alongside
          the consumer.

          This is sometimes used to include patched modules, but whenver
          possible bundling should be avoided in favor of tooling like `esbuild`
          or `webpack` because the effect bundled dependencies have on
          resolution is fraught.
        '';
        type    = nt.bool;
        default = false;
      };

      # Indicates whether the dependency is required for various preparation
      # phases or jobs.
      runtime = lib.mkOption {
        description = ''
          Whether the dependency is required at runtime.
          Other package management tools often refer to these as
          "production mode" dependencies.
        '';
        type    = nt.bool;
        default = false;
      };

      dev = lib.mkOption {
        description = ''
          Whether the dependency is required during pre-distribution phases.
          This includes common tasks such as building, testing, and linting.
        '';
        type    = nt.bool;
        default = true;
      };

    };  # End `options'

  };  # End `depInfoEntryDeferred'


  depInfoBaseEntry         = nt.submodule depInfoBaseEntryDeferred;
  mkDepInfoBaseEntryOption = lib.mkOption {
    type        = depInfoBaseEntry;
    default     = {};
    description = lib.mdDoc ''
      Describes a single dependency "edge" consumed by a package/module.

      In addition to the base fields, arbitrary `boolean` fields may be defined
      for use by extensions.
    '';
  };


# ---------------------------------------------------------------------------- #

  depInfoBaseDeferredWith = extraEntryModules: {
    _file        = "<libfloco>/types/depInfo/base.nix:depInfoBaseDeferredWith";
    freeformType = nt.attrsOf ( nt.submodule (
      [depInfoBaseEntryDeferred] ++ ( lib.toList extraEntryModules )
    ) );
  };

  depInfoBaseWith = extraEntryModules:
    nt.submodule ( depInfoBaseDeferredWith extraEntryModules );

  depInfoBase = depInfoBaseWith [];


  mkDepInfoBaseOptionWith = extraEntryModules: lib.mkOption {
    description = lib.mdDoc ''
      Information regarding dependency modules/packages.
      This record is analogous to the various
      `package.json:.[dev|optional|bundled]Dependencies[Meta]` fields.

      These config settings do note necessarily dictate the contents of the
      `treeInfo` configs, which are used by builders, but may be used to provide
      information needed to generate trees if they are not defined.
    '';
    type    = depInfoBaseWith extraEntryModules;
    default = {};
  };

  mkDepInfoBaseOption = mkDepInfoBaseOptionWith [];


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  inherit
    depInfoBaseEntryDeferred
    depInfoBaseEntry
    mkDepInfoBaseEntryOption

    depInfoBaseDeferredWith
    depInfoBaseWith
    depInfoBase
    mkDepInfoBaseOptionWith
    mkDepInfoBaseOption
  ;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
