# ============================================================================ #
#
# A `options.flocoPackages.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib
, config
, flocoPackages ? config._module.args.flocoPackages
, ...
}: {

# ---------------------------------------------------------------------------- #

  config = {
    # An example module, but also there's basically a none percent chance that
    # a real build plan won't include this so yeah you depend on `lodash' now.
    packages = {
      lodash."4.17.21".pdef = { ident = "lodash"; version = "4.17.21"; };
    } // ( builtins.mapAttrs ( _: builtins.mapAttrs ( _: pdef: {
      inherit pdef;
    } ) ) flocoPackages.pdefs );
  };  # End `config'

# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
