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
      };  # End `options.installed.type'
    };  # End `options.installed'
  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
