# ============================================================================ #
#
# A `options.flocoPackages.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

  nt = lib.types;
  ft = import ./types.nix { inherit lib; };

in {

# ---------------------------------------------------------------------------- #

  imports = [./depInfo ./peerInfo];


# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    ident = lib.mkOption {
      description = ''
        Package identifier/name as found in `package.json:.name'.
      '';
      type = ft.ident;
    };


# ---------------------------------------------------------------------------- #

    version = lib.mkOption {
      description = ''
        Package version as found in `package.json:.version'.
      '';
      type = ft.version;
    };


# ---------------------------------------------------------------------------- #

    key = lib.mkOption {
      description = ''
        Unique key used to refer to this package in `tree' submodules and other
        `floco' configs, metadata, and structures.
      '';
      type = ft.key;
    };


# ---------------------------------------------------------------------------- #

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
      type    = ft.ltype;
      default = "file";
    };


# ---------------------------------------------------------------------------- #

    lifecycle = lib.mkOption {
      description = ''
        Enables/disables phases executed when preparing a package/module for
        consumption or installation.

        Executing a phase when no associated script is defined is not
        necessarily harmful, but has a drastic impact on performance and may
        cause infinite recursion if dependency cycles exist among packages.

        See Also: ltype
      '';
      default = { build = false; install = false; };
      type    = ft.lifecycle;
    };


# ---------------------------------------------------------------------------- #

    inherit (import ../fetchInfo/interfaces.nix { inherit lib; }) fetchInfo;

# ---------------------------------------------------------------------------- #

    sourceInfo = lib.mkOption {
      description = ''
        Information about the source tree a package resides in.
        This record is analogous to that returned by `builtins.fetchTree' for
        flake inputs.

        Used in combination with `fetchInfo' and `fsInfo.dir', these three
        nuggets of metadata are isomorphic with a flake input.

        However, unlike flake inputs, `sourceInfo.outPath' may set to a derived
        store path if and only if `fetchInfo' is explicitly set to `null'.
        In this case `fsInfo.dir' is still used to identify a pacakage/module's
        root directory where we will attempt to read `package.json'
        ( must exist ) and similar metadata files will be read from
        ( if they exist ).
        In this case you may avoid IFD by explicitly setting top level fields,
        specifically `lifecycle', `sysInfo', `binInfo', and `treeInfo' or
        `depInfo' which are required by builders.
        Alternatively you may explicitly set `metaFiles.{pjs,plock,plent,trees}'
        fields directly - but keep in mind that these fields are never
        guaranteed to be stable and their schema may change at any time
        ( so set the top level ones unless you're up for the maintanence ).
      '';
      type = nt.submodule {
        freeformType = nt.attrsOf ( nt.oneOf [nt.bool nt.int nt.str] );
        options.outPath = lib.mkOption {
          description = ''
            A Nix Store path containing the unpacked source tree in which this
            package/module resides.
            The package need not be at the root this path; but when the project
            root is a subdir the option `fsInfo.dir' must be set in order for
            `package.json' and other metadata to be translated.
          '';
          type = nt.path;
        };
      };
    };


# ---------------------------------------------------------------------------- #

    sysInfo = lib.mkOption {
      description = ''
        Indicates platform, arch, and Node.js version support.
      '';
      type = nt.submodule {
        options = {
          os      = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
          cpu     = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
          engines = lib.mkOption {
            type = nt.submodule {
              freeformType = nt.attrsOf nt.str;
              options.node = lib.mkOption { type = nt.str; default = "*"; };
            };
          };
        };
      };
      default = {
        os           = ["*"];
        cpu          = ["*"];
        engines.node = "*";
      };
    };


# ---------------------------------------------------------------------------- #

    binInfo = lib.mkOption {
      description = ''
        Indicates files or directories which should be prepared for use as
        executable scripts.
      '';
      type = nt.submodule {
        options.binPairs = lib.mkOption {
          description = ''
            Pairs of `{ <EXE-NAME> = <REL-PATH>; ... }' declarations mapping
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
      };
      default.binPairs = {};
    };


# ---------------------------------------------------------------------------- #

    treeInfo = lib.mkOption {
      description = ''
        `node_modules/' trees used for various lifecycle events.
        These declarations are analogous to the `package.*' field found in
        `package-lock.json(v2/3)' files.
        This means that these fields should describe both direct and indirect
        dependencies for the full dependency graph.

        Tree declarations are expected to be pairs of `node_modules/' paths to
        "keys" ( matching the `key' field in its Nix declaration ):
        {
          "node_modules/@foo/bar"                  = "@foo/bar/1.0.0";
          "node_modules/@foo/bar/node_modules/baz" = "baz/4.2.0";
          ...
        }

        Arbitrary trees may be defined for use by later builders; but by default
        we expect `prod' to be defined for any `file' ltype packages which
        contain executables or an `install' event, and `dev' to be defined for
        any packages which have a `build' lifecycle event.

        In practice we expect users to explicitly define these fields only for
        targets which they actually intend to create installables from, and we
        recommend using a `package-lock.json(v2/3)' to fill these values.
      '';
      type = nt.submodule {
        freeformType = nt.attrsOf nt.str;
        options.dev  = lib.mkOption { type = nt.attrsOf nt.str; default = {}; };
        options.prod = lib.mkOption { type = nt.attrsOf nt.str; default = {}; };
      };
      default = { dev = {}; prod = {}; };
    };



# ---------------------------------------------------------------------------- #

    fsInfo = lib.mkOption {
      description = ''
        Indicates information about a package that must be scraped from its
        source tree, rather than a conventional config file.

        It is not recommended for users to manually fill these fields; rather
        we expect these to be informed by a cache or lockfile.
        You're welcome to explicitly define them, but I don't want to see anyone
        griping about these options in bug reports.
      '';
      type = nt.submodule {
        options.gypfile = lib.mkOption {
          description = ''
            Whether `binding.gyp' exists in the project root.
            May be explicitly overridden by declarations in `package.json'.

            WARNING: You must not set this field based on ANY metadata pulled
            from a registry.
            There is a bug in NPM v8 that caused thousands of registry
            packuments and vinfo records to be poisoned, and in addition to that
            there is conflicting reporting rules for this field in POST requests
            by various package managers such that you should effectively
            disregard the value entirely.
          '';
          type    = nt.bool;
          default = false;
        };
        options.dir = lib.mkOption {
          description = ''
            Relative path from `sourceInfo.outPath' to the package's root.
            This field is analogous to a flake input's `dir' field, and is
            used in combination with `fetchInfo' in exactly the same way as
            a flake input.

            You should almost never need to set this field for distributed
            tarballs ( only if it contains bundled dependencies ).

            While this field is useful for working with monorepos I strongly
            recommend that you avoid abusing it.
            Its use inherently causes rebuilds of all projects in associated
            with a single `sourceInfo' record for any change in the subtree.
            It is much more efficient to split a subtree into multiple sources,
            but I've left you enough rope to learn things the hard way if you
            insist on doing so.
            Consider yourself warned.
          '';
          type    = nt.str;
          default = ".";
        };
      };
      default = { gypfile = false; dir = "."; };
    };


# ---------------------------------------------------------------------------- #

    # TODO: These fields really don't need to exist anymore since the NixOS
    # module system itself already provides these abstractions.
    # Because the entire beta repository uses `metaFiles.*' as its equivalent
    # of `config.*' "submodules" I'm basically just including this as a
    # temporary submodule to assist with migration.
    #
    # Whether or not this field will exist in the future is uncertain - but from
    # the perspective of users these fields are strictly internal and the
    # documentation below is eventually going to be moved into individual
    # translators associated with each filetype.
    metaFiles = lib.mkOption {
      internal    = true;
      description = ''
        Misc. raw config info pulled from various config files.
        In general these are used to fill other fields as fallbacks when
        explicit definitions are not given.

        Note that while builders will never directly refer to these fields -
        unless explicitly locked, these sub-options may trigger impure
        evaluation if builders attempt to reference them indirectly to derive
        defaults/fallbacks for other options.

        While other parts of a package's schema are strictly defined and can be
        treated as "stable" - `metaFiles' fields should be thought of as
        "internal" and may change or be extended to support new translators.

        For this reason let me be loud and clear:
        If you write a builder that directly refers to a `metaFiles' field, and
        it breaks because of a change to the `metaFiles' schema, and you proceed
        to file a bug report - you will be asked to stand in the corner of the
        classroom on top of your desk for the remainder of the day.
        Consider yourself warned.
      '';
      type = nt.submodule {

        options = {

# ---------------------------------------------------------------------------- #

          metaRaw = lib.mkOption {
            description = ''
              Explicit metadata provided by users as a form of override or
              method of caching.
              This field is optional and while many translators may reference it
              I want to once again highlight that ALL `metaFiles' fields are
              strictly internal and should never be relied upon by builders or
              external extensions to `floco' since they may change without
              warning or indication in semantic versioning of the framework.
            '';
            type    = nt.attrsOf nt.anything;
            default = {};
          };


# ---------------------------------------------------------------------------- #

          pjs = lib.mkOption {
            description = "Raw contents of `package.json'.";
            type = nt.attrsOf nt.anything;
          };

          pjsDir = lib.mkOption {
            description = ''
              Path to the directory containing `package.json'.
              We require this path so that we can fetch source trees declared as
              relative paths in the `package.json' under `dependencies' ( and
              similar ) and `workspaces' fields.

              NOTE: If your `package.json' contains `../*' relative paths it is
              strongly recommended that this option be set to a non-store path.
              If a store path such as `/nix/store/xxxxx-source/../some-dir' is
              given, Nix will crash and burn attempting to fetch `some-dir'.
              A common trick to ensure that you are passing a regular filesystem
              path is to stringize as: `pjsDir = toString ./.;'.
            '';
            type    = nt.path;
            example = toString ./my-project;
          };

          pjsKey = lib.mkOption {
            description = ''
              For `package.json' files with workspaces, the `pjsKey' is used to
              identify a workspace member.

              These keys are simply a relative path from the "root" `pjsDir' to
              a sub-project's `pjsDir'.

              NOTE: This field is currently unused by `floco', but is future
              extensions will use it to support workspaces.
            '';
            type    = nt.str;
            default = "";
          };


# ---------------------------------------------------------------------------- #

          plock = lib.mkOption {
            description = ''
              Raw contents of `package-lock.json'.

              NOTE: This field must only be set when the "root" package in the
              lockfile is associated this the package being declared.
              Information concerning dependencies is instead stashed
              in `metaFiles.plent.*'.

              See Also: plent
            '';
            type    = nt.nullOr ( nt.attrsOf nt.anything );
            default = null;
          };

          plent = lib.mkOption {
            description = ''
              Raw contents of a `package-lock.json:.packages.*' record.

              See Also: plock plentKey
            '';
            type    = nt.nullOr ( nt.attrsOf nt.anything );
            default = null;
          };

          lockDir = lib.mkOption {
            description = ''
              Path to the directory containing `package-lock.json'.
              We require this path so that we can fetch source trees declared as
              relative paths in the lockfile.

              NOTE: If your lockfile contains `../*' relative paths it is
              strongly recommended that this option be set to a non-store path.
              If a store path such as `/nix/store/xxxxx-source/../some-dir' is
              given, Nix will crash and burn attempting to fetch `some-dir'.
              A common trick to ensure that you are passing a regular filesystem
              path is to stringize as: `lockDir = toString ./.;'.
            '';
            type    = nt.nullOr nt.path;
            default = null;
            example = toString ./my-project;
          };

          plentKey = lib.mkOption {
            description = ''
              The key used to lookup a plent in `package-lock.json:.packages.*'.
              This key is a relative path from `lockDir' to the prospective
              `pjsDir' of a package/module.
            '';
            type    = nt.nullOr nt.str;
            default = null;
            example = "node_modules/@babel/core/node_modules/semver";
          };


# ---------------------------------------------------------------------------- #

          #packument = lib.mkOption {
          #  description = ''
          #    Raw contents from a package registry concerning all published
          #    versions of a package/module.

          #    See Also: packumentUrl, vinfo
          #  '';
          #  type    = nt.nullOr ( nt.attrsOf nt.anything );
          #  default = null;
          #};

          #packumentUrl = lib.mkOption {
          #  description = ''
          #    Registry URL where "packument" information can be fetched.
          #    A packument contains information about all published versions of
          #    a package, and is commonly used to resolve package `descriptors'
          #    such as `^1.0.0' to a version such as `1.2.3'.

          #    This field is optional and may be set to `null' to avoid looking
          #    up projects which are not published to a registry, or to avoid
          #    processing packument metadata.

          #    NOTE: Processing packument metadata is not required when another
          #    form metadata such as `treeInfo' or `depInfo' is available for
          #    `floco' to construct a `node_modules/' tree with.
          #    Packuments are most useful for extensions to `floco' to perform
          #    tasks like auto-updating projects when new versions are published.
          #  '';
          #  type    = nt.nullOr nt.str;
          #  default = null;
          #  example = "https://registry.npmjs.org/lodash";
          #};

          #packumentHash = lib.mkOption {
          #  description = ''
          #    SHA256 hash used to lock and purify fetching of
          #    packument metadata.
          #    In practice you likely want to automate updates to this hash since
          #    it will be invalidated every time a new version of a package is
          #    published to the registry.

          #    To lock onto a specific version of a package you may find that the
          #    `vinfo' metadata is better suited for locking.

          #    See Also: packumentUrl, packumentRev, vinfoUrl
          #  '';
          #  type    = nt.nullOr nt.str;
          #  default = null;
          #};

          #packumentRev = lib.mkOption {
          #  description = ''
          #    Revision information associated with a packument.
          #    In combination with `packumentHash' this value could potentially
          #    be used to immitate a Nix input's lockfile entry.

          #    This revision information is provided under the `_rev' field of
          #    a packument, and is formatted as `<REV-COUNT>-<COMMITISH-HASH>'.

          #    NOTE: At time of writing this field is unused, but future
          #    extensions to `floco' intend to use this field to write packument
          #    information to `flake.lock'.
          #  '';
          #  type    = nt.nullOr nt.str;
          #  default = null;
          #  example = "2722-2d3b98d05acf18018581dd0b19bc2bfc";
          #};


# ---------------------------------------------------------------------------- #

          #vinfo = lib.mkOption {
          #  description = ''
          #    Short for "version information".

          #    Raw contents from a package registry concerning a specific version
          #    of a package/module.

          #    See Also: vinfoUrl, packument
          #  '';
          #  type    = nt.nullOr ( nt.attrsOf nt.anything );
          #  default = null;
          #};

          #vinfoUrl = lib.mkOption {
          #  description = ''
          #    Short for "version information".

          #    Registry metadata concerning a specific version of a package.
          #    This record is an expanded form of the
          #    "abbreviated version information" found in a
          #    `packument.versions.*' field.

          #    Because `vinfo' records are almost never updated, if you intend to
          #    lock and purify lookups of project metadata - it is strongly
          #    recommended that you do so using `vinfo' rather an packument.
          #  '';
          #  type = nt.nullOr nt.str;
          #  default = null;
          #  example = "https://registry.npmjs.org/lodash/4.17.21";
          #};

          #vinfoHash = lib.mkOption {
          #  description = ''
          #    SHA256 hash used to lock and purify fetching of
          #    version-info metadata.
          #  '';
          #  type = nt.nullOr nt.str;
          #  default = null;
          #};


# ---------------------------------------------------------------------------- #

          trees = lib.mkOption {
            description = ''
              Raw `treeInfo' style metadata, conventionally being sets of
              `{ test = { "node_modules/@foo/bar" = "@foo/bar/1.0.0"; ... }; }'
              mappings used for deriving a full `treeInfo' record.

              NOTE: It is strongly recommended that users write `treeInfo'
              directly if they wish to declare those settings.
              This attribute exists for interop with the beta implementation of
              `floco' ( `github:aameen-tulip/at-node-nix' ).
            '';
            type    = nt.nullOr ( nt.attrsOf nt.anything );
            default = null;
          };


# ---------------------------------------------------------------------------- #

        };  # End `metaFiles.type.options'
      };  # End `metaFiles.type'

      default = {};
    };  # End `metaFiles'


# ---------------------------------------------------------------------------- #

    _export = lib.mkOption {
      internal    = true;
      description = ''
        This should never be explicitly defined by users or config files.
        This field exists to allow a locked representation of a package
        definition to be made available at eval time in order to debug/trace
        the fields available to builders, and restrict the fields which are
        readable across modules for the formation of `treeInfo' options.
      '';
      type = nt.lazyAttrsOf nt.anything;
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
