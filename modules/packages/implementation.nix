# ============================================================================ #
#
# A `options.flocoPackages.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

  config = {
    # An example module, but also there's basically a none percent chance that
    # a real build plan won't include this so yeah you depend on `lodash' now.
    packages = builtins.mapAttrs ( _: builtins.mapAttrs ( _: pdef: {
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
