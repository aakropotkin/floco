# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  findCfg = apath: let
    jpath = apath + ".json";
    jfile = if builtins.pathExists jpath then jpath else null;
    npath = apath + ".nix";
    nfile = if builtins.pathExists npath then npath else null;
  in if nfile != null then nfile else jfile;

  xdgConfigHome = let
    x = builtins.getEnv "XDG_CONFIG_HOME";
  in if x != "" then x else ( builtins.getEnv "HOME" ) + "/.config";

  fromVarOr = var: fallback: let
    v = builtins.getEnv var;
  in if v == "" then fallback else v;

in {
  system    ? fromVarOr "_nix_system" builtins.currentSystem
, flocoRef  ? fromVarOr "_floco_ref" ( toString ../../.. )
, floco     ? builtins.getFlake flocoRef
, lib       ? floco.lib
, globalCfg ? fromVarOr "_g_floco_cfg" ( findCfg /etc/floco/floco-cfg )
, userCfg   ? fromVarOr "_u_floco_cfg"
                        ( findCfg ( xdgConfigHome + "/floco/floco-cfg" ) )
, localCfg  ? fromVarOr "_l_floco_cfg"
                        ( findCfg ( ( builtins.getEnv "PWD" ) + "/floco-cfg" ) )
, extraCfg  ? {}
, pkgsFor   ? floco.lib.pkgsFor.${system}
, ...
}: let

# ---------------------------------------------------------------------------- #

  modules = let
    nnull = builtins.filter ( x: ! ( builtins.elem x [null "" "null"] ))
                            [globalCfg userCfg localCfg];
    load  = f:
      if lib.test ".*\\.json" f then lib.modules.importJSON f else f;
  in map load nnull;

  mod = lib.evalModules {
    modules = modules ++ [
      floco.nixosModules.default
      { config.floco.settings = { inherit system; }; }
      extraCfg
    ];
  };


# ---------------------------------------------------------------------------- #

  pdefsExport = builtins.mapAttrs ( _: builtins.mapAttrs ( _: v: v._export ) )
                                  mod.config.floco.pdefs;


# ---------------------------------------------------------------------------- #

in {

  inherit
    system
    flocoRef
    floco
    lib
    globalCfg
    userCfg
    localCfg
    pkgsFor
    modules
    mod
    pdefsExport
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
