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
  in {

    treeInfo = lib.mkDefault (
      if config ? metaFiles.metaRaw.treeInfo
      then config.metaFiles.metaRaw.treeInfo
      else if need == {} then {} else null
    );

    _export  = lib.mkIf ( config.treeInfo != null ) {
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
