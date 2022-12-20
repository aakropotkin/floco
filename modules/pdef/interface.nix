# ============================================================================ #
#
# A `options.flocoPackages.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let
  nt = lib.types;
in {

# ---------------------------------------------------------------------------- #

  options = {

    ident = lib.mkOption {
      description = ''
        Package identifier/name as found in `package.json:.name'.
      '';
      type = nt.strMatching "(@[^@/]+/)?[^@/]+";
    };

    version = lib.mkOption {
      description = ''
        Package version as found in `package.json:.version'.
      '';
      type = let
        da_c      = "[[:alpha:]-]";
        dan_c     = "[[:alnum:]-]";
        num_p     = "(0|[1-9][[:digit:]]*)";
        part_p    = "(${num_p}|[0-9]*${da_c}${dan_c}*)";
        core_p    = "${num_p}(\\.${num_p}(\\.${num_p})?)?";
        tag_p     = "${part_p}(\\.${part_p})*";
        build_p   = "${dan_c}+(\\.[[:alnum:]]+)*";
        version_p = "${core_p}(-${tag_p})?(\\+${build_p})?";
      in nt.strMatching version_p;
    };

    key = lib.mkOption {
      description = ''
        Unique key used to refer to this package in `tree' submodules and other
        `floco' configs, metadata, and structures.
      '';
      type = nt.str;
    };

    ltype = lib.mkOption {
      description = ''
        Package "lifecycle type"/"pacote source type".
        This option effects which lifecycle events may run when preparing a
        package/module for consumption or installation.

        For example, the `file' ( distributed tarball ) lifecycle does not run
        any `scripts.[pre|post]build' phases or result in any `devDependencies'
        being added to the build plan - since these packages will have been
        "built" before distribution.
        However, `scripts.[pre|post]install' scripts ( generally `node-gyp'
        compilation ) does run for the `file' lifecycle.

        This option is effectively a shorthand for setting `lifecycle' defaults,
        but may also used by some fetchers and scrapers.

        See Also: lifecycle, fetchInfo
      '';
      type    = nt.enum ["file" "link" "dir" "git"];
      default = "file";
    };

    lifecycle = lib.mkOption {
      description = ''
        Enables/disables phases executed when preparing a package/module for
        consumption or installation.

        Executing a phase when no associated script is defined is not
        necessarily harmful, but has a drastic impact on performance and may
        cause infinite recursion if dependency cycles exist among packages.

        See Also: ltype
      '';
      type = nt.submodule {
        options = {
          build   = lib.mkOption { type = nt.bool; default = false; };
          install = lib.mkOption { type = nt.bool; default = false; };
        };
      };
    };

    depInfo = lib.mkOption {
      description = ''
        Information regarding dependency modules/packages.
        This record is analogous to the various
        `package.json:.[dev|peer|optional|bundled]Dependencies[Meta]' fields.

        These config settings do note necessarily dictate the contents of the
        `trees' configs, which are used by builders, but may be used to provide
        information needed to generate trees if they are not defined.
      '';
      type = nt.attrsOf ( nt.submodule {
        options = {
          descriptor     = lib.mkOption { type = nt.nullOr nt.str; };
          peerDescriptor = lib.mkOption { type = nt.nullOr nt.str; };
          pin            = lib.mkOption { type = nt.nullOr nt.str; };

          optional = lib.mkOption { type = nt.bool; default = false; };
          peer     = lib.mkOption { type = nt.bool; default = false; };
          bundled  = lib.mkOption { type = nt.bool; default = false; };

          # Indicates whether the dependency is required for various preparation
          # phases or jobs.
          runtime = lib.mkOption { type = nt.bool; default = true; };
          dev     = lib.mkOption { type = nt.bool; default = false; };
          test    = lib.mkOption { type = nt.bool; default = false; };
          lint    = lib.mkOption { type = nt.bool; default = false; };
        };
        check = v:
          ( ( v ? descriptor ) || ( v ? peerDescriptor ) ) &&
          ( ( v.peer or false ) -> ( v ? peerDescriptor ) );
      } );
      default = {};
    };

  };  # End `options'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
