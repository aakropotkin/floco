# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/source/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    source = lib.mkOption {
      description = lib.mdDoc ''
        Unpacked source tree used as the basis for package/module preparation.

        It is strongly recommended that you use `config.pdef.sourceInfo` here
        unless you are intentionally applying patches, filters, or your package
        resides in a subdir of `sourceInfo`.

        XXX: This tree should NOT patch shebangs yet, since this would deprive
        builders which produce distributable tarballs or otherwise "un-nixify" a
        module of an "unpatched" point of reference to work with.
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

  };  # End `options'


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
