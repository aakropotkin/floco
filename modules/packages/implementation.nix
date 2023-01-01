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
    flocoPackages.packages = {
      lodash."4.17.21" = { ident = "lodash"; version = "4.17.21"; };
    };
  };  # End `config'

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
