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

    options.packages = lib.mkOption {
      type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [
          {
            _module.args = {
              pkgs  = lib.mkDefault pkgs;
              floco = config;
            };
          }
          ../package/implementation.nix
        ];
      } ) );
    };


# ---------------------------------------------------------------------------- #

  config = {

    # An example module, but also there's basically a none percent chance that
    # a real build plan won't include this so yeah you depend on `lodash' now.
    packages = builtins.mapAttrs ( ident: builtins.mapAttrs ( version: pdef: {
      inherit (pdef) key;
      inherit pdef;
    } ) ) config.pdefs;
  };  # End `config'

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
