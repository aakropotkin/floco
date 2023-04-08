# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pdefs, deriveTreeInfo, ... }: {

# ---------------------------------------------------------------------------- #

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
    in deriveTreeInfo &&
       depsPinned &&
       ( builtins.all pred ( builtins.attrNames need ) );

    linked = let
      proc = ident: {
        name  = "node_modules/${ident}";
        value = {
          inherit (need.${ident}) optional;
          link = true;
          key  = ident + "/" + need.${ident}.pin;
          dev  = need.${ident}.dev && ( ! need.${ident}.runtime );
        };
      };
    in builtins.listToAttrs ( map proc ( builtins.attrNames need ) );

    cond = ( config.metaFiles.metaRaw.treeInfo or null ) != null ||
           ( need == {} ) || canLinkDeps;
  in {

    treeInfo = lib.mkDefault (
      config.metaFiles.metaRaw.treeInfo or (
        if need == {} then {} else
        if cond then linked else null
      )
    );

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
