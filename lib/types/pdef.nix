# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  peerInfoBaseEntryDeferred = {
    _file        = "<libfloco>/types/pdef.nix:peerInfoBaseEntryDeferred";
    freeformType = nt.attrsOf nt.bool;
    options      = {
      inherit (lib.libfloco.depInfoBaseEntryDeferred.options)
        descriptor optional
      ;
    };
  };

  peerInfoBaseEntry = nt.submodule peerInfoBaseEntryDeferred;

  peerInfoBase         = nt.attrsOf peerInfoBaseEntry;
  mkPeerInfoBaseOption = lib.mkOption {
    description = lib.mdDoc ''
      Set of propagated dependencies that consumers of this package/module
      must provide at runtime.

      Often peer dependencies are used to enforce interface alignment across
      a set of modules but do not necessarily imply that the requestor depends
      on the declared peer at build time or runtime - rather it states
      "my consumers depend on the declared peer as a side effect of their
      dependence on me".
    '';
    type    = peerInfoBase;
    default = {};
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    peerInfoBaseEntryDeferred
    peerInfoBaseEntry
    peerInfoBase
    mkPeerInfoBaseOption
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
