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

  # nnullp :: any -> bool
  # ---------------------
  # Predicate which returns true if `x' is not-null or non-empty.
  # This rejects empty environment variables, those which were explicitly set
  # to "null", and primitive `null' values.
  nnullp = x: ! ( builtins.elem x [null "" "null"] );


# ---------------------------------------------------------------------------- #

  system = fromVarOr "_nix_system" builtins.currentSystem;

  flocoRef = let
    devPath  = toString ../../../../flake.nix;
    fallback = if builtins.pathExists devPath then devPath else
               "github:aakropotkin/floco";
  in fromVarOr "_floco_ref" fallback;

  floco = builtins.getFlake flocoRef;


# ---------------------------------------------------------------------------- #

  # Impurely lookup various config files from environment variables or fallbacks
  # in standard locations on the system.

  globalConfig = fromVarOr "_g_floco_cfg" ( findCfg /etc/floco/floco-cfg );

  userConfig = fromVarOr "_u_floco_cfg"
                         ( findCfg ( xdgConfigHome + "/floco/floco-cfg" ) );

  localConfig =
    fromVarOr "_l_floco_cfg"
              ( findCfg ( ( builtins.getEnv "PWD" ) + "/floco-cfg" ) );

  # `extraConfig' may be either a file path or a `nix' expression as a string.
  # For example this works:
  #   $ _e_floco_cfg='{ floco.pdefs.lodash."4.17.21" = { ... } }'  \
  #   $   floco show lodash 4.17.21;
  extraConfig = let
    val       = fromVarOr "_e_floco_cfg" null;
    asFile    = builtins.toFile "extra-cfg.nix" val;
    isAbsPath = ( builtins.match "/.*" val ) != null;
  in if val == null then null else
     if isAbsPath && ( builtins.pathExists val ) then val else
     builtins.unsafeDiscardStringContext asFile;


# ---------------------------------------------------------------------------- #

  # Impurely lookup config files that can be consumed as modules, filtering out
  # empty/missing ones.
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

  # Impurely lookup the `basedir' of the target `localConfig' file or `PWD'
  # which should be used to write relative paths in written files.
  getBasedir = {
    localConfig ? null
  , basedir     ?
    if nnullp localConfig then dirOf localConfig else builtins.getEnv "PWD"
  , ...
  } @ env: basedir;


# ---------------------------------------------------------------------------- #

in {
  inherit system flocoRef floco;
  lib = let
    local = if ! ( builtins.pathExists ./default.nix ) then {} else
            import ./. { inherit (floco.inputs.nixpkgs) lib; };
  in if local == {} then floco.lib else local.extend floco.lib;
  inherit globalConfig userConfig localConfig extraConfig;
  inherit getConfigModules getBasedir;
  pkgsFor = builtins.getAttr system floco.pkgsFor;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
