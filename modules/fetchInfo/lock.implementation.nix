# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ config, ... }: {
  config.fetchInfo = if ! (
    ( builtins.elem config.fetchInfo.type ["file" "tarball"] ) &&
    ( config.fetchInfo.narHash == null )
  ) then config.fetchInfo else config.fetchInfo // {
    narHash = ( builtins.fetchTree {
      inherit (config.fetchInfo) type url;
    } ).narHash;
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
