# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, pdef, pdefs, packages, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/trees/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.warnings = lib.mkIf (
    ( pdef.treeInfo == null )
  ) ( if pdef.lifecycle.install || pdef.lifecycle.build then [''
    The package `${pdef.key}' requires a build or install, but no
    `treeInfo' has been defined.
    Installations and builds will be executed without a `node_modules/' tree
    unless you explicitly define `treeInfo'.
  ''] else [] );


# ---------------------------------------------------------------------------- #

  config.trees = let
    mkTree = args: let
      fn = import ../../../builders/treeFromInfo.nix;
      real = lib.callPackageWith {
        inherit (pkgs) system coreutils findutils jq bash;
        inherit packages pdefs;
      } fn args;
      ext = real // {
        overrideAttrs = ov: let
          prev  = real.drvAttrs // real.passthru;
          final = if lib.isFunction ov then ov prev else prev // ov;
          match = builtins.intersectAttrs ( lib.functionArgs fn ) final;
        in mkTree match;
      };
    in if ( args.treeInfo or {} ) == {} then null else ext;
    cond = pdef.treeInfo != null;
  in {

# ---------------------------------------------------------------------------- #

    supported = lib.mkIf cond ( lib.filterAttrs ( k: v: let
      ident   = dirOf v.key;
      version = baseNameOf v.key;
    in ( ! v.optional ) ||
      packages.${ident}.${version}.systemSupported
    ) pdef.treeInfo );


# ---------------------------------------------------------------------------- #

    prod = lib.mkIf cond ( lib.mkDefault ( mkTree {
      treeInfo = lib.filterAttrs ( _: { dev ? false, ... }: ! dev )
                                 config.trees.supported;
    } ) );


# ---------------------------------------------------------------------------- #

    dev = lib.mkIf cond ( lib.mkDefault ( mkTree {
      treeInfo = config.trees.supported;
    } ) );


# ---------------------------------------------------------------------------- #

  };  # End `config.trees'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
