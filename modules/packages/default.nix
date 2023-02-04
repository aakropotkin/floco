# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/packages";

# ---------------------------------------------------------------------------- #

  options.packages = lib.mkOption {

    description = lib.mdDoc ''
      Collection of built/prepared packages and modules.
    '';

    type = nt.lazyAttrsOf ( nt.lazyAttrsOf ( nt.submodule {
      modules = [../package];
    } ) );

    example.lodash."4.17.21".key = "lodash/4.17.21";

  };


# ---------------------------------------------------------------------------- #

  config = {

    records.config._module.args = {
      inherit pkgs;
      floco = config;
    };
    # An example module, but also there's basically a none percent chance that
    # a real build plan won't include this so yeah you depend on `lodash' now.
    packages = builtins.mapAttrs ( ident: builtins.mapAttrs ( version: pdef:
      {
        config = {
          inherit (pdef) key;
          _module.args = {
            inherit pkgs pdef;
            inherit (config) packages pdefs;
          };
        };
      }
    ) ) config.pdefs;
  };  # End `config'

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
