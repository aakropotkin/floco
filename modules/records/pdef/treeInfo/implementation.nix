# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pdefs, buildPlan, ... }: {

  _file = "<floco>/records/pdef/treeInfo/implementation.nix";

# ---------------------------------------------------------------------------- #

  config = let
    prod = lib.filterAttrs ( _: v: v.runtime or false ) config.depInfo;
    need = if config.lifecycle.build then config.depInfo else prod;

    depsPinned = builtins.all ( v: ( v.pin or null ) != null )
                              ( builtins.attrValues need );
    canLinkDeps = let
      pred = ident: let
        dpdef = lib.getPdef { inherit pdefs; } {
          inherit ident;
          version = need.${ident}.pin;
        };
      in ( ( need.${ident}.pin or null ) != null ) &&
         ( dpdef != null ) &&
         ( ( dpdef.treeInfo or null ) != null );
    in buildPlan.deriveTreeInfo &&
       depsPinned &&
       ( builtins.all pred ( builtins.attrNames need ) );

    linked = let
      proc = acc: ident: acc // {
        "node_modules/${ident}" = {
          inherit (need.${ident}) optional;
          link = true;
          key  = ident + "/" + need.${ident}.pin;
          dev  = need.${ident}.dev && ( ! need.${ident}.runtime );
        };
      };
    in builtins.foldl' proc {} ( builtins.attrNames need );

    cond = ( config.metaFiles.metaRaw.treeInfo or null ) != null ||
           ( need == {} ) || canLinkDeps;
  in {

    treeInfo = lib.mkIf cond ( lib.mkDefault (
      config.metaFiles.metaRaw.treeInfo or (
        if need == {} then {} else linked
      )
    ) );

    _export = lib.mkIf ( cond || ( ( config.treeInfo or null ) != null ) ) {
      treeInfo = let
        subs = import ./single.interface.nix { inherit lib; };
      in builtins.mapAttrs ( _: e: lib.filterAttrs ( f: v:
        ( v != ( subs.options.${f}.default or false ) )
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
