# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/implementation.nix";

  imports = [
    ../buildPlan
    ../fetchers
    ../pdefs
  ];

# ---------------------------------------------------------------------------- #

  config.records = {
    _module.args.fetchers  = lib.mkDefault config.fetchers;
    _module.args.pkgs      = lib.mkDefault pkgs;
    _module.args.buildPlan = lib.mkDefault config.buildPlan;
    _module.args.pdefs     = lib.mkDefault config.pdefs;
  };  # End `config.records'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
