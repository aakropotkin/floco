# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, flocoPackages, ... }: {

# ---------------------------------------------------------------------------- #

  config.warnings = lib.mkIf (
    ( config.pdef.treeInfo == null )
  ) ( if config.pdef.lifecycle.install || config.pdef.lifecycle.build then [''
    The package `${config.pdef.key}' requires a build or install, but no
    `treeInfo' has been defined.
    Installations and builds will be executed without a `node_modules/' tree
    unless you explicitly define `treeInfo'.
  ''] else [] );


# ---------------------------------------------------------------------------- #

  config.trees = let
    mkTree = args: let
      real = lib.callPackageWith {
        inherit (pkgs) system coreutils findutils jq bash;
        inherit flocoPackages;
      } ( import ../../../builders/tree.nix ) args;
    in if ( args.keyTree or args.pathTree or {} ) == {} then null else real;
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
