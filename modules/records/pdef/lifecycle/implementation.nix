# ============================================================================ #
#
# Controls the execution of lifecycle events.
# When set to `true' preparation of a module will run a given event first.
#
# Some events like `test', `lint', and `dist' only block preparation when
# certain `floco.packages.<IDENT>.<VESION>.*' settings explicitly
# request them to.
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/pdef/lifecycle/implementation.nix";

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    lifecycle.build = let
      fromLtype   = ! ( builtins.elem config.ltype ["file" "link"] );
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

    # Only export `lifecycle' if it indicates non-default values.
    _export = let
      subs       = options.lifecycle.type.getSubOptions [];
      nonDefault = f: v: v != ( subs.${f}.default or false );
      rsl        = builtins.mapAttrs ( f: v: lib.mkIf ( nonDefault f v ) v )
                                     config.lifecycle;
      any = ( lib.filterAttrs nonDefault config.lifecycle ) != {};
    in lib.mkIf any { lifecycle = rsl; };


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
