# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: {

  checkSystemSupportFor = config: {
    stdenv   ? throw "checkSystemSupport: You must pass an arg"
  , platform ? stdenv.hostPlatform
  , system   ? platform.system
  }: let
      m        = builtins.match "(.*)-([^-]+)" system;
      archPart = builtins.head m;
      archOk   = ( builtins.elem "*" config.sysInfo.cpu ) ||
                 ( builtins.elem archPart config.sysInfo.cpu );
      osPart = builtins.elemAt m 1;
      osOk   = ( builtins.elem "*" config.sysInfo.os ) ||
               ( builtins.elem osPart config.sysInfo.os );
    in archOk && osOk;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
