# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

  config = let
    prod = lib.filterAttrs ( _: v: v.runtime or false ) config.depInfo;
    need = if config.lifecycle.build then config.depInfo else prod;
    cond = ( config ? metaFiles.metaRaw.treeInfo ) || ( need == {} );
  in {

    treeInfo = lib.mkIf cond ( lib.mkDefault (
      config.metaFiles.metaRaw.treeInfo or {}
    ) );

    _export = lib.mkIf cond {
      treeInfo = let
        subs = import ./single.interface.nix { inherit lib; };
      in builtins.mapAttrs ( _: e: builtins.mapAttrs ( f: v:
        lib.mkIf ( v != ( subs.options.${f}.default or false ) ) v
      ) e ) config.treeInfo;
    };

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
