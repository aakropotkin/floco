# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

# ---------------------------------------------------------------------------- #

  config = let
    prod    = lib.filterAttrs ( _: v: v.runtime or false ) config.depInfo;
    need    = if config.lifecycle.build then config.depInfo else prod;
    fromRaw = builtins.mapAttrs ( _: v:
      if builtins.isString v then { key = v; } else v
    ) config.metaFiles.metaRaw.treeInfo;
  in {
    treeInfo = lib.mkDefault (
      if config ? metaFiles.metaRaw.treeInfo then fromRaw else
      if need == {} then {} else null
    );
    _export  = lib.mkIf ( config.treeInfo != null ) {
      treeInfo = let
        subs = import ./single.interface.nix { inherit lib; };
      in builtins.mapAttrs ( _: e: let
           min = builtins.mapAttrs ( f: v:
            lib.mkIf ( v != ( subs.options.${f}.default or false ) ) v
           ) e;
           filt = lib.filterAttrs ( f: v:
             ( f == "key" ) || ( v != ( subs.options.${f}.default or false ) )
           ) e;
         in if ( builtins.attrNames filt ) == ["key"] then filt.key else min
      ) config.treeInfo;
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
