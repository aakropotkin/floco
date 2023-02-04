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

  mkCachedRec = lib.mapAttrsRecursive ( _: mkCached );


# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/records/pdef/deserialize.nix";

  config.binInfo      = mkCachedRec options.binInfo.default;
  config.depInfo      = mkCached {};
  config.peerInfo     = mkCached {};
  config.sysInfo      = mkCachedRec options.sysInfo.default;
  config.lifecycle    = mkCachedRec options.lifecycle.default;
  config.fsInfo       = mkCachedRec options.fsInfo.default;
  config.deserialized = true;

  # We explicitly set this to empty to prevent various routines from trying to
  # fetch the file contents.
  # This ensures that only the declared information is used.
  config.metaFiles.pjs   = mkCached {};
  config.metaFiles.plent = mkCached {};
  config.metaFiles.ylent = mkCached {};

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
