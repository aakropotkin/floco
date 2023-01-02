# ============================================================================ #
#
# Controls the execution of lifecycle events.
# When set to `true' preparation of a module will run a given event first.
#
# Some events like `test', `lint', and `dist' only block preparation when
# certain `flocoPackages.packages.<IDENT>.<VESION>.*' settings explicitly
# request them to.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    lifecycle.build = let
      fromLtype   = config.ltype != "file";
      fromScripts = let
        s = config.metaFiles.metaRaw.scripts or config.metaFiles.pjs.scripts or
            {};
      in if ! ( config ? metaFiles.pjs ) then true else
         ( s ? prebuild ) || ( s ? build ) || ( s ? postbuild ) ||
         ( s ? prepublish );
    in lib.mkDefault (
      config.metaFiles.metaRaw.lifecycle.build or ( fromLtype && fromScripts )
    );


# ---------------------------------------------------------------------------- #

    lifecycle.install = let
      fromScripts = let
        s = config.metaFiles.metaRaw.scripts or config.metaFiles.pjs.scripts or
            {};
      in ( s ? preinstall ) || ( s ? install ) || ( s ? postinstall );
      gypfile = config.metaFiles.metaRaw.gypfile or
                config.metaFiles.pjs.gypfile or
                config.fsInfo.gypfile;
    in lib.mkDefault (
      config.metaFiles.metaRaw.lifecycle.install or
      config.metaFiles.plent.hasInstallScript or ( fromScripts || gypfile )
    );


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
