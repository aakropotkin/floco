# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, floco, ... }: {

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
        inherit floco;
      } ( import ../../../builders/tree.nix ) args;
    in if ( args.keyTree or args.pathTree or {} ) == {} then null else real;
    cond = config.pdef.treeInfo != null;
  in {

# ---------------------------------------------------------------------------- #

    supported = lib.mkIf cond ( lib.filterAttrs ( k: v: let
      ident   = dirOf v.key;
      version = baseNameOf v.key;
    in ( ! v.optional ) ||
      floco.packages.${ident}.${version}.systemSupported
    ) config.pdef.treeInfo );


# ---------------------------------------------------------------------------- #

    prod = lib.mkIf cond ( lib.mkDefault ( mkTree {
      keyTree = let
        keeps = lib.filterAttrs ( _: { dev ? false, ... }: ! dev )
                                config.trees.supported;
      in builtins.mapAttrs ( _: v: v.key ) keeps;
    } ) );


# ---------------------------------------------------------------------------- #

    dev = lib.mkIf cond ( lib.mkDefault ( mkTree {
      keyTree = builtins.mapAttrs ( _: v: v.key ) config.trees.supported;
    } ) );


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
