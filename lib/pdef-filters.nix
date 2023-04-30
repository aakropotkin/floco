# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  noArgs = {

# ---------------------------------------------------------------------------- #

    hasInstall = p: p.lifecycle.install or false;
    hasBuild   = p: p.lifecycle.build   or false;


# ---------------------------------------------------------------------------- #

    isLocal   = p: p.fetchInfo.type == "path";
    isRemote  = p: p.fetchInfo.type != "path";
    isGit     = p: builtins.elem p.fetchInfo.type ["git" "github" "gitlab"];
    isTarball = p: p.fetchInfo.type == "tarball";


# ---------------------------------------------------------------------------- #

    hasPeers   = p: p.peerInfo != {};
    hasBundled = p:
      builtins.any ( de: de.bundled or false )
                   ( builtins.attrValues p.depInfo );


# ---------------------------------------------------------------------------- #

    needsOS          = p: p.sysInfo.os  != ["*"];
    needsCPU         = p: p.sysInfo.cpu != ["*"];
    needsNodeVersion = p: ( p.sysInfo.engines.node or "*" ) != "*";


# ---------------------------------------------------------------------------- #

  };  # End `noArgs'


# ---------------------------------------------------------------------------- #

  withArgs = {

    supportsOS = os: p:
      ( builtins.elem "*" p.sysInfo.os ) ||
      ( builtins.elem os p.sysInfo.os );

    supportsCPU = cpu: p:
      ( builtins.elem "*" p.sysInfo.cpu ) ||
      ( builtins.elem cpu p.sysInfo.cpu );

    supportsSystem = system: p:
      lib.libfloco.checkSystemSupportFor p { inherit system; };

  };


# ---------------------------------------------------------------------------- #

in noArgs // withArgs // { pdefFilters = { inherit noArgs withArgs; }; }


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
