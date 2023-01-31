# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, options, config, pkgs, ... }: let

  nt   = lib.types;
  oloc = builtins.length options.pdefs.loc;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdefs/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.pdefs = lib.mkOption {
    type = nt.lazyAttrsOf ( nt.lazyAttrsOf ( nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { options, fetcher, fetchers, basedir, pdefs, ... }: let
          inherit (options.key) loc;
        in {
          imports = [config.records.pdef];
          config._module.args.fetchers = lib.mkDefault config.fetchers;
          config._module.args.pkgs     = lib.mkDefault pkgs;
          config._module.args.pdefs    = lib.mkDefault config.pdefs;

          # Priority prefers low numbers - "low priority" means "big number",
          # "high priority" means "low number".
          # The lowest priority is 1500 which is used by
          # `lib.mkOption { default = <VAL>; }', followed by `lib.mkDefault'
          # which uses 1000.
          # We want this fallback to float around the low end so 1400 is fine.
          config.ident   = lib.mkOverride 1400 ( builtins.elemAt loc oloc );
          config.version =
            lib.mkOverride 1400 ( builtins.elemAt loc ( oloc + 1 ) );
        } )
      ];
    } ) );
    default = {};
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
