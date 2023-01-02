# ============================================================================ #
#
# Prevents default values from being exported.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  config = let
    subs = options.sysInfo.type.getSubOptions [];
    rsl = if config.sysInfo == options.sysInfo.default then {} else {
      os  = lib.mkIf ( config.sysInfo.os != subs.os.default ) config.sysInfo.os;
      cpu = lib.mkIf ( config.sysInfo.cpu != subs.cpu.default )
                     config.sysInfo.cpu;
      engines = lib.mkIf ( config.sysInfo.engines != subs.engines.default )
                         config.sysInfo.engines;
    };
  in lib.mkIf ( rsl != {} ) { _export.sysInfo = rsl; };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
