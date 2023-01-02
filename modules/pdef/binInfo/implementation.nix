# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #


    config.binInfo = let

      bin = config.metaFiles.metaRaw.bin or (
        if config.metaFiles ? plent then config.metaFiles.plent.bin or {} else
        if config.metaFiles ? pjs then config.metaFiles.pjs.bin or {} else
        null
      );

      binDir = lib.mkDefault (
        if bin != null then null else
        config.metaFiles.metaRaw.binDir or
        config.metaFiles.metaRaw.directories.bin or
        config.metaFiles.pjs.directories.bin or null
      );

    in lib.mkDefault ( config.metaFiles.metaRaw.binInfo or {
      inherit binDir;
      binPairs = lib.mkDefault (
        if bin == null then null else
        if builtins.isAttrs bin then bin else
        { ${baseNameOf config.ident} = bin; }
      );

    } );


# ---------------------------------------------------------------------------- #

    config._export = let
      subs = options.binInfo.type.getSubOptions [];
    in lib.mkIf ( config.binInfo != options.binInfo.default ) {
      binInfo = {
        binDir = lib.mkIf ( config.binInfo.binDir != subs.binDir.default )
                          config.binInfo.binDir;
        binPairs = lib.mkIf ( config.binInfo.binPairs != subs.binPairs.default )
                            config.binInfo.binPairs;
      };
    };


# ---------------------------------------------------------------------------- #

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
