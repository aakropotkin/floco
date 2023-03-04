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

  imports = [../fetchers];

# ---------------------------------------------------------------------------- #

  config.records = {

    _module.args.pkgs  = lib.mkDefault pkgs;
    _module.args.floco = lib.mkDefault config;

    depInfo = { config, ... }: {
      deferred = lib.mkDefault ( lib.libfloco.depInfoGenericMemberWith {
        inherit (config) extraModules extraEntryModules;
      } );
    };

  };  # End `config.records'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
