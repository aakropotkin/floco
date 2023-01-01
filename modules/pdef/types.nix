# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  version = let
    da_c      = "[[:alpha:]-]";
    dan_c     = "[[:alnum:]-]";
    num_p     = "(0|[1-9][[:digit:]]*)";
    part_p    = "(${num_p}|[0-9]*${da_c}${dan_c}*)";
    core_p    = "${num_p}(\\.${num_p}(\\.${num_p})?)?";
    tag_p     = "${part_p}(\\.${part_p})*";
    build_p   = "${dan_c}+(\\.[[:alnum:]]+)*";
    version_p = "${core_p}(-${tag_p})?(\\+${build_p})?";
  in nt.strMatching version_p;


# ---------------------------------------------------------------------------- #

  ident = nt.strMatching "(@[^@/]+/)?[^@/]+";


# ---------------------------------------------------------------------------- #

  key = nt.str;


# ---------------------------------------------------------------------------- #

  ltype = nt.enum ["file" "link" "dir" "git"];


# ---------------------------------------------------------------------------- #

  lifecycle = nt.submodule {
    freeformType = nt.attrsOf nt.bool;
    options = {
      build   = lib.mkOption {
        description = ''
          Whether a package or module requires build scripts to be run before
          it is prepared for consumption.
          
          This field should never be set to true when consuming registry
          tarballs even if they define build scripts, since they are distributed
          after being built by authors and maintainers.
        '';
        type    = nt.bool;
        default = false;
      };
      install = lib.mkOption {
        description = lib.mdDoc ''
          Whether a package or module requires `[pre|post]install` scripts or
          `node-gyp` compilation to be performed before a distributed tarball
          is prepared for consumption.
        '';
        type    = nt.bool;
        default = false;
      };
    };
  };


# ---------------------------------------------------------------------------- #

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
