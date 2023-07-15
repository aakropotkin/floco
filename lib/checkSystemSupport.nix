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
      archOk   = let
        hasStar  = builtins.elem "*" config.sysInfo.cpu;
        pn       = builtins.partition ( lib.hasPrefix "!" ) config.system.cpu;
        hasMatch = builtins.elem archPart pn.wrong;
        hasNope  = builtins.elem ( "!" + archPart ) pn.right;
        pred     = assert ( ( builtins.length pn.right ) == 0 ) ||
                          ( ( builtins.length pn.wrong ) == 0 );
                   if ( builtins.length pn.right ) == 0 then hasMatch
                                                        else ! hasNope;
      in hasStar || pred;
      osPart = builtins.elemAt m 1;
      osOk   = let
        hasStar  = builtins.elem "*" config.sysInfo.os;
        pn       = builtins.partition ( lib.hasPrefix "!" ) config.system.os;
        hasMatch = builtins.elem archPart pn.wrong;
        hasNope  = builtins.elem ( "!" + archPart ) pn.right;
        pred     = assert ( ( builtins.length pn.right ) == 0 ) ||
                          ( ( builtins.length pn.wrong ) == 0 );
                   if ( builtins.length pn.right ) == 0 then hasMatch
                                                        else ! hasNope;
      in hasStar || pred;
    in archOk && osOk;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
