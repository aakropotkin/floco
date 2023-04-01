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
, flocoRef  ? fromVarOr "FLOCO_REF" "github:aakropotkin/floco"
, floco     ? builtins.getFlake flocoRef
, lib       ? floco.lib
, globalCfg ? fromVarOr "_g_floco_cfg" ( findCfg /etc/floco/floco-cfg )
, userCfg   ? fromVarOr "_u_floco_cfg"
                        ( findCfg ( xdgConfigHome + "/floco/floco-cfg" ) )
, localCfg  ? fromVarOr "_l_floco_cfg"
                        ( findCfg ( ( builtins.getEnv "PWD" ) + "/floco-cfg" ) )

, outfile             ? builtins.getEnv "OUTFILE"
, asJSON              ? ( builtins.getEnv "JSON" ) != ""
, includePins         ? ( builtins.getEnv "PINS" ) != ""
, includeRootTreeInfo ? ( builtins.getEnv "TREE" ) != ""
, lockDir             ? /. + ( builtins.getEnv "LOCKDIR" )
}: let

  cfg = let
    nnull = builtins.filter ( x: ! ( builtins.elem x [null "" "null"] ))
                            [globalCfg userCfg localCfg];
    load  = f:
      if lib.test ".*\\.json" f then lib.modules.importJSON f else f;
  in map load nnull;

  mod = lib.evalModules {
    modules = cfg ++ [
      floco.nixosModules.plockToPdefs
      { config._module.args.basedir = /. + ( dirOf outfile ); }
      {
        config.floco = {
          buildPlan.deriveTreeInfo = false;
          inherit includePins includeRootTreeInfo lockDir;
        };
      }
    ];
  };

  contents.floco.pdefs = mod.config.floco.exports;
in if asJSON then contents else lib.generators.toPretty {} contents


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
