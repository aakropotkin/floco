# ============================================================================ #
#
# Prevents default values from being exported.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/sysInfo/implementation.nix";

  config.sysInfo = let
    get = f:
      config.metaFiles.metaRaw.${f} or
      config.metaFiles.plent.${f} or
      config.metaFiles.pjs.${f} or
      null;
  in {

    os = let
      v = get "os";
      npmOSToNixOSMap = {
        darwin   = "darwin";
        freebsd  = "freebsd";
        netbsd   = "netbsd";
        linux    = "linux";
        openbsd  = "openbsd";
        sunos    = "sunprocess";
        sunos-64 = "sunprocess";
        solaris  = "sunprocess";
        win32    = "win32";
        # Unsupported:
        aix     = "unknown";
        android = "unknown";
      };
    in lib.mkDefault (
      if v == null then ["*"] else
      lib.unique ( map ( c: npmOSToNixOSMap.${c} or "unknown" ) v )
    );

    cpu = let
      v = get "cpu";
      npmCpuToNixArchMap = {
        x64      = "x86_64";
        ia32     = "i686";
        arm      = "aarch";
        arm64    = "aarch64";
        s390x    = "unknown";
        ppc64    = "powerpc64le";
        mips64el = "mipsel";
        riscv64  = "riscv64";
        loong64  = "unknown";
      };
    in lib.mkDefault (
      if v == null then ["*"] else
      lib.unique ( map ( c: npmCpuToNixArchMap.${c} or "unknown" ) v )
    );
  };

  config._export = let
    subs = options.sysInfo.type.getSubOptions [];
    rsl = if config.sysInfo == options.sysInfo.default then {} else {
      os  = lib.mkIf ( config.sysInfo.os != subs.os.default ) config.sysInfo.os;
      cpu = lib.mkIf ( config.sysInfo.cpu != subs.cpu.default )
                     config.sysInfo.cpu;
      engines = lib.mkIf ( config.sysInfo.engines != subs.engines.default )
                         config.sysInfo.engines;
    };
  in lib.mkIf ( rsl != {} ) { sysInfo = rsl; };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
