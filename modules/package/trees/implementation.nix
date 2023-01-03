# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, flocoPackages, ... }: {

# ---------------------------------------------------------------------------- #

  config.trees = let
    mkTree = lib.callPackageWith {
      inherit (pkgs) coreutils findutils jq bash;
      inherit flocoPackages;
    } ( import ../../../builders/tree.nix );
  in lib.mkIf ( config.pdef.treeInfo != null ) {

# ---------------------------------------------------------------------------- #

    supported = lib.filterAttrs ( k: v: let
      ident   = dirOf v.key;
      version = baseNameOf v.key;
    in ( ! v.optional ) ||
      flocoPackages.packages.${ident}.${version}.systemSupported
    ) config.pdef.treeInfo;


# ---------------------------------------------------------------------------- #

    prod = lib.mkDefault ( mkTree {
      keyTree = let
        keeps = lib.filterAttrs ( _: { dev ? false, ... }: ! dev )
                                config.trees.supported;
      in builtins.mapAttrs ( _: v: v.key ) keeps;
    } );


# ---------------------------------------------------------------------------- #

    dev = lib.mkDefault ( mkTree {
      keyTree = builtins.mapAttrs ( _: v: v.key ) config.trees.supported;
    } );


# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #

  };  # End `config.trees'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
