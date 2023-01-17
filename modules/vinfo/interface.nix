# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/vinfo/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    vinfo = lib.mkOption {
      description = ''
        Short for "version information".

        Raw contents from a package registry concerning a specific version
        of a package/module.

        See Also: vinfoUrl, packument
      '';
      type    = nt.nullOr ( nt.attrsOf nt.anything );
      default = null;
    };


# ---------------------------------------------------------------------------- #

    vinfoUrl = lib.mkOption {
      description = lib.mdDoc ''
        Short for "version information".

        Registry metadata concerning a specific version of a package.
        This record is an expanded form of the
        "abbreviated version information" found in a
        `packument.versions.*` field.

        Because `vinfo` records are almost never updated, if you intend to
        lock and purify lookups of project metadata - it is strongly
        recommended that you do so using `vinfo` rather an packument.
      '';
      type = nt.nullOr nt.str;
      default = null;
      example = "https://registry.npmjs.org/lodash/4.17.21";
    };


# ---------------------------------------------------------------------------- #

    vinfoHash = lib.mkOption {
      description = ''
        SHA256 hash used to lock and purify fetching of version-info metadata.
      '';
      type = nt.nullOr nt.str;
      default = null;
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
