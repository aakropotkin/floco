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


  sysOsList = [
    "*" "darwin" "freebsd" "netbsd" "linux" "openbsd" "sunprocess"
    "win32" "unknown"
  ];

  sysOssType = let
    base = lib.libfloco.uniqueListOf ( nt.enum sysOsList );
  in base // {
    merge = loc: defs: let
      ul = base.merge loc defs;
    in if builtins.any ( x: x == "*" ) ul then ["*"] else ul;
  };

  mkSysOssOption = lib.mkOption {
    description = lib.mdDoc ''
      List of supported operating systems.
      The string `"*"` indicates that all operating systems
      are supported.
    '';
    type    = sysOssType;
    default = ["*"];
  };


# ---------------------------------------------------------------------------- #


  sysCpuList = [
    "*" "x86_64" "i686" "aarch" "aarch64" "powerpc64le" "mipsel"
    "riscv64" "unknown"
  ];

  sysCpusType = let
    base = lib.libfloco.uniqueListOf ( nt.enum sysCpuList );
  in base // {
    merge = loc: defs: let
      ul = base.merge loc defs;
    in if builtins.any ( x: x == "*" ) ul then ["*"] else ul;
  };

  mkSysCpusOption = lib.mkOption {
    description = lib.mdDoc ''
      List of supported CPU architectures.
      The string `"*"` indicates that all CPUs are supported.
    '';
    type    =  sysCpusType;
    default = ["*"];
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    peerInfoBaseEntryDeferred
    peerInfoBaseEntry
    peerInfoBase
    mkPeerInfoBaseOption
  ;

  inherit
    sysOsList
    sysOssType
    mkSysOssOption
    sysCpuList
    sysCpusType
    mkSysCpusOption
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
