# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: let

# ---------------------------------------------------------------------------- #

  # We use `priority' of 900 to put us above `lib.mkDefault', while staying
  # below `lib.mkForce'.
  # This allows users' `foverrides.nix'/explicit config to still "work",
  # while avoiding the network fetches and other scraping which may occur if
  # we hit `lib.mkDefault'
  mkCached = lib.mkOverride 900;


# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/pdef/deserialize.nix";

  config.binInfo   = mkCached options.binInfo.default;
  config.depInfo   = mkCached {};
  config.peerInfo  = mkCached {};
  config.sysInfo   = mkCached options.sysInfo.default;
  config.fsInfo    = mkCached options.fsInfo.default;
  config.lifecycle = mkCached options.lifecycle.default;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
