# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let
  impure = import ./lib/impure.nix;
in {
  system       ? impure.system
, flocoRef     ? impure.flocoRef
, floco        ? impure.floco
, lib          ? impure.lib
, pkgsFor      ? impure.pkgsFor
, globalConfig ? impure.globalConfig
, userConfig   ? impure.userConfig
, localConfig  ? impure.localConfig
, extraConfig  ? impure.extraConfig
, basedir      ? impure.getBasedir args
, ...
} @ args: let

# ---------------------------------------------------------------------------- #

  configModules = impure.getConfigModules args;

  modules = configModules ++ [
    floco.nixosModules.default
    { config.floco.settings = { inherit system basedir; }; }
  ];

  mod = lib.evalModules { inherit modules; };


# ---------------------------------------------------------------------------- #

in {

  inherit (impure // args)
    system
    flocoRef
    floco
    lib
    pkgsFor
    globalConfig
    userConfig
    localConfig
    extraConfig
  ;

  inherit
    args
    basedir
    configModules
    modules
    mod
  ;

  pdefsExport = builtins.mapAttrs ( _: builtins.mapAttrs ( _: v: v._export ) )
                                  mod.config.floco.pdefs;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
