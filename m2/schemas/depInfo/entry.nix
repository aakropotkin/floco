# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

  name        = "depInfoEntry";
  description = ''
    A dependency declaration.
  '';

  type.submodule = {
    # Additional bool fields may be added in association with various lifecycle
    # events such as `test', `lint', etc allowing users to minimize the trees
    # used for those events.
    freeformType = { attrsOf = "bool"; };

    options = {

      descriptor = let
        type = (import ../generic.nix).descriptor;
      in {
        inherit (type) description;
        inherit type;
        default = "*";
      };

      optional = {
        description =  ''
          Whether the dependency may be omitted from the `node_modules/` tree
          during post-distribution phases.

          Conventionally this is used to mark dependencies which are only
          required under certain conditions such as platform, architecture,
          or engines.
          Generally optional dependencies carry `sysInfo` conditionals, or
          `postinstall` scripts which must be allowed to fail without blocking
          the build of the consumer.
        '';
        type    = "bool";
        default = false;
      };

      bundled = {
        description = ''
          Whether the dependency is distributed in registry tarballs alongside
          the consumer.

          This is sometimes used to include patched modules, but whenver
          possible bundling should be avoided in favor of tooling like `esbuild`
          or `webpack` because the effect bundled dependencies have on
          resolution is fraught.
        '';
        type    = "bool";
        default = false;
      };

      # Indicates whether the dependency is required for various preparation
      # phases or jobs.
      runtime = {
        description = ''
          Whether the dependency is required at runtime.
          Other package management tools often refer to these as
          "production mode" dependencies.
        '';
        type    = "bool";
        default = false;
      };

      dev = {
        description = ''
          Whether the dependency is required during pre-distribution phases.
          This includes common tasks such as building, testing, and linting.
        '';
        type    = "bool";
        default = true;
      };

    };  # End `options'

  };  # End `type.submodule'

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
