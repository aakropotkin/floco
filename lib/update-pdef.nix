# ============================================================================ #
#
# Utilities for updating `pdef' records, and collections of `pdef' records.
#
# Largely this aims to cherry pick fields that are "known to be good",
# particularly info scraped from registry manifests/tarballs, vs. info that may
# be dirty such as local project manifests, `depInfo.*.pin' fields, `treeInfo',
# and similar info.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  registryPreserves = {
    key        = true;
    ident      = true;
    version    = true;
    ltype      = true;  # *
    fetchInfo  = true;  # *
    sourceInfo = true;  # *
    binInfo    = true;  # *
    depInfo    = {
      descriptor = true;
      pin        = false;  # ***
      optional   = true;
      bundled    = true;
      runtime    = true;
      dev        = true;
    };
    peerInfo     = true;  # only okay because it doesn't contain pins
    sysInfo      = true;
    fsInfo       = true;
    lifecycle    = true;
    treeInfo     = false;  # ***
    metaFiles    = false;  # ***
    deserialized = false;  # ***
    _export      = false;  # *** Contains `treeInfo' and `depInfo'
  };


# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #

in {

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
