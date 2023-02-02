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

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/built/interface.nix";

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
      };  # End `options.built.type'
    };  # End `options.built'
  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
