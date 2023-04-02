# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

  impure = import ../lib/impure.nix;

in {
  system       ? impure.system
, flocoRef     ? impure.flocoRef
, floco        ? impure.floco
, lib          ? impure.lib
, globalConfig ? impure.globalConfig
, userConfig   ? impure.userConfig
, localConfig  ? impure.localConfig
, extraConfig  ? impure.extraConfig

, outfile             ? builtins.getEnv "OUTFILE"
, asJSON              ? ( builtins.getEnv "JSON" ) != ""
, includePins         ? ( builtins.getEnv "PINS" ) != ""
, includeRootTreeInfo ? ( builtins.getEnv "TREE" ) != ""
, lockDir             ? /. + ( builtins.getEnv "LOCKDIR" )
} @ args: let

  configModules = impure.getConfigModules args;

  mod = lib.evalModules {
    modules = configModules ++ [
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
