# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  config = {

    fsInfo.gypfile = lib.mkDefault (
      builtins.pathExists ( config.metaFiles.pjsDir + "/binding.gyp" )
    );

    fsInfo.shrinkwrap = lib.mkDefault (
      builtins.pathExists ( config.metaFiles.pjsDir + "/npm-shrinkwrap.json" )
    );

    _export = let
      subs = options.fsInfo.type.getSubOptions [];
      rsl  = if config.fsInfo == options.fsInfo.default then {} else {
        dir = lib.mkIf ( config.fsInfo.dir != subs.dir.default )
                       config.fsInfo.dir;
        gypfile = lib.mkIf ( config.fsInfo.gypfile != subs.gypfile.default )
                           config.fsInfo.gypfile;
        shrinkwrap =
          lib.mkIf ( config.fsInfo.shrinkwrap != subs.shrinkwrap.default )
                   config.fsInfo.shrinkwrap;
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
