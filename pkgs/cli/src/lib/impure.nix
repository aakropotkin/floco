# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

# ---------------------------------------------------------------------------- #

  # findCfg :: path -> ( path |null )
  # ---------------------------------
  # Locate a config file by path accepting either `.nix' or `.json' extensions.
  findCfg = apath: let
    jpath = apath + ".json";
    jfile = if builtins.pathExists jpath then jpath else null;
    npath = apath + ".nix";
    nfile = if builtins.pathExists npath then npath else null;
  in if nfile != null then nfile else jfile;


# ---------------------------------------------------------------------------- #

  # xdgConfigHome :: path
  # ---------------------
  # Lookup `XDG_CONFIG_HOME' or fallback to `$HOME/.config'.
  xdgConfigHome = let
    x = builtins.getEnv "XDG_CONFIG_HOME";
  in if x != "" then x else ( builtins.getEnv "HOME" ) + "/.config";


# ---------------------------------------------------------------------------- #

  # fromVarOr :: string -> any -> ( string | any )
  # ----------------------------------------------
  # Load a value from an environment variable, or fallback to a given default
  # if the environment variable is unset/empty.
  fromVarOr = var: fallback: let
    v = builtins.getEnv var;
  in if v == "" then fallback else v;


# ---------------------------------------------------------------------------- #

  system = fromVarOr "_nix_system" builtins.currentSystem;

  flocoRef = let
    devPath  = toString ../../../../flake.nix;
    fallback = if builtins.pathExists devPath then devPath else
               "github:aakropotkin/floco";
  in fromVarOr "_floco_ref" fallback;

  floco = builtins.getFlake flocoRef;


# ---------------------------------------------------------------------------- #

  globalConfig = fromVarOr "_g_floco_cfg" ( findCfg /etc/floco/floco-cfg );

  userConfig = fromVarOr "_u_floco_cfg"
                         ( findCfg ( xdgConfigHome + "/floco/floco-cfg" ) );

  localConfig =
    fromVarOr "_l_floco_cfg"
              ( findCfg ( ( builtins.getEnv "PWD" ) + "/floco-cfg" ) );

  extraConfig = let
    val    = fromVarOr "_e_floco_cfg" null;
    asFile = builtins.toFile "extra-cfg.nix" val;
  in if val == null then null else
     if builtins.pathExists val then val else
     builtins.unsafeDiscardStringContext asFile;


# ---------------------------------------------------------------------------- #

  nnullp = x: ! ( builtins.elem x [null "" "null"] );


# ---------------------------------------------------------------------------- #

  getConfigModules = { ... } @ env: let
    nnull = builtins.filter nnullp [
      ( env.globalConfig or globalConfig )
      ( env.userConfig   or userConfig )
      ( env.localConfig  or localConfig )
      ( env.extraConfig  or extraConfig )
    ];
    load = f:
      if ( builtins.match ".*\\.json" f ) == null then f else
      floco.lib.modules.importJSON f;
  in map load nnull;


# ---------------------------------------------------------------------------- #

  getBasedir = {
    localConfig ? null
  , basedir     ?
    if nnullp localConfig then dirOf localConfig else builtins.getEnv "PWD"
  , ...
  } @ env: basedir;


# ---------------------------------------------------------------------------- #

in {
  inherit system flocoRef floco;
  inherit (floco) lib;
  inherit globalConfig userConfig localConfig extraConfig;
  inherit getConfigModules getBasedir;
  pkgsFor = builtins.getAttr system floco.pkgsFor;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
