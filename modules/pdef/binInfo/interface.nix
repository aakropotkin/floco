# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.binInfo = lib.mkOption {

    description = lib.mdDoc ''
      Indicates files or directories which should be prepared for use as
      executable scripts.
    '';

    default = { binPairs = {}; binDir = null; };

# ---------------------------------------------------------------------------- #

    type = nt.submodule {

        options.binPairs = lib.mkOption {
          description = lib.mdDoc ''
            Pairs of `{ <EXE-NAME> = <REL-PATH>; ... }` declarations mapping
            exposed executables scripts to their associated sources.
          '';
          type = nt.attrsOf nt.str;
          default = {};
        };

        options.binDir = lib.mkOption {
          description = ''
            Relative path to a subdir from which all files should be prepared
            as executables.
            Executable names will be defined as the basename of each file with
            any extensions stripped.
          '';
          type    = nt.nullOr nt.str;
          default = null;
        };

    };  # End `options.binInfo.type.options'


# ---------------------------------------------------------------------------- #

  };  # End `options.binInfo'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
