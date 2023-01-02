# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  config = {

    fsInfo.gypfile = lib.mkDefault (
      config.metaFiles.plent.gypfile or
      ( builtins.pathExists ( config.metaFiles.pjsDir + "/binding.gyp" ) )
    );

    _export = let
      subs = options.fsInfo.type.getSubOptions [];
      rsl  = if config.fsInfo == options.fsInfo.default then {} else {
        dir = lib.mkIf ( config.fsInfo.dir != subs.dir.default )
                       config.fsInfo.dir;
        gypfile = lib.mkIf ( config.fsInfo.gypfile != subs.dir.gypfile )
                           config.fsInfo.gypfile;
      };
    in lib.mkIf ( rsl != {} ) { fsInfo = rsl; };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
