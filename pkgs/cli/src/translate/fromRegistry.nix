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

  # Sets low priority on potentially stale fields in `pdef' records.
  moduleForUpdate = impure.lib.libfloco.prepConfigForUpdate' {
    flocoTopModule = floco.nixosModules.floco;
    configModules  = impure.getConfigModules args;
    settingsModule = {
      config.floco.settings = { inherit system; basedir = lockDir; };
    };
  };

  mod = lib.evalModules {
    modules = [
      moduleForUpdate
      floco.nixosModules.plockToPdefs
      {
        config._module.args.basedir = /. + ( dirOf outfile );
        config._module.args.lockDir = lockDir;
        config.floco = {
          buildPlan.deriveTreeInfo = false;
          inherit includePins includeRootTreeInfo lockDir;
        };
      }
    ];
  };

  base   = mod.config.floco.exports;
  phony  = base."@floco/phony"."0.0.0-0";
  target = builtins.head ( builtins.attrNames phony.depInfo );
  ppath  = "node_modules/" + target;
  tver   = baseNameOf phony.treeInfo.${ppath}.key;
  pplen  = ( builtins.stringLength ppath ) + 1;

  treeInfo = let
    np    = removeAttrs phony.treeInfo [ppath];
    remap = p: {
      name  = builtins.substring pplen ( builtins.stringLength p ) p;
      value = np.${p};
    };
  in builtins.listToAttrs ( map remap ( builtins.attrNames np ) );

  contents.floco.pdefs = let
    np = removeAttrs base ["@floco/phony"];
  in if ! includeRootTreeInfo then np else np // {
    ${target} = base.${target} // {
      ${tver} = base.${target}.${tver} // { inherit treeInfo; };
    };
  };

in if asJSON then contents else lib.generators.toPretty {} contents


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
