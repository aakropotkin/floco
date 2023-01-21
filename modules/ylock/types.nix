# ============================================================================ #
#
# Types associated with individual `yarn.lock' entries.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;
  ft = import ../pdef/types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  ylockMetadata = nt.submodule {

    options.version = lib.mkOption {
      description = lib.mdDoc ''
        `yarn.lock` schema version.
      '';
      type    = nt.int;
      default = 5;
    };

    options.cacheKey = lib.mkOption {
      description = lib.mdDoc ''
        Indicates version and compression level information about `yarn` cache
        associated with the lockfile.
        This can largely be ignored but it effects `checksum` values for
        projects with installation scripts or patches, so it may be relevant to
        those who extend `floco`.
      '';
      type    = nt.int;
      example = 8;
    };

  };


# ---------------------------------------------------------------------------- #

  ylent = nt.submodule {

# ---------------------------------------------------------------------------- #

    freeformType = nt.attrsOf nt.anything;

    options = {

# ---------------------------------------------------------------------------- #

      descriptors = lib.mkOption {
        description = lib.mdDoc ''
          Descriptors associated with a `ylock` entry.
          This list indicates that the given descriptors should resolve to this
          entry throughout the lockfile when they appear in `dependencies` and
          similar fields.

          In `yarn.lock` a comma separated form of this list is used to key
          top level entries.
        '';
        type    = nt.listOf nt.str;
        example = [
          "@aws-crypto/sha256-js@npm:^1.0.0"
          "@aws-crypto/sha256-js@npm:^1.1.0"
        ];
      };

      ident = lib.mkOption {
        description = lib.mdDoc ''
          Package identifier/name as found in `package.json:.name'.
        '';
        type = ft.ident;
      };

      version = lib.mkOption {
        description = lib.mdDoc ''
          Package version as found in `package.json:.version`.
        '';
        type = ft.version;
      };

      key = lib.mkOption {
        description = lib.mdDoc ''
          Unique key used to refer to this package in `tree` submodules and
          other `floco' configs, metadata, and structures.
        '';
        type = ft.key;
      };


# ---------------------------------------------------------------------------- #

      dependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };

      devDependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };

      devDependenciesMeta = lib.mkOption {
        type    = nt.attrsOf ( nt.attrsOf nt.bool );
        default = {};
      };

      peerDependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };

      peerDependenciesMeta = lib.mkOption {
        type    = nt.attrsOf ( nt.attrsOf nt.bool );
        default = {};
      };

      optionalDependencies = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
      };


# ---------------------------------------------------------------------------- #

      bin = lib.mkOption {
        description = ''
          Pairs of `{ <NAME> = <REL-PATH>; ... }' indicating executables that
          will installed, and their associated source code to be symlinked.

          These can be used "as is" to set `<PKG-ENT>.binInfo.binPairs'.
        '';
        type    = nt.attrsOf nt.str;
        default = {};
        example = { "semver" = "bin/semver.js"; };
      };


# ---------------------------------------------------------------------------- #

      resolution = lib.mkOption {
        description = lib.mdDoc ''
          Locator string representing the location of a package/module's source.
          These use a URI syntax specific to `yarn` and are more similar to
          package decriptor URIs than they are to `resolved` URIs in `npm`.
        '';
        type    = nt.str;
        example = "@aws-sdk/middleware-host-header@npm:3.226.0";
        # resolution: "@foo/bar@workspace:projects/bar"
      };

      checksum = lib.mkOption {
        description = lib.mdDoc ''
          SHA512 hash ( non-SRI ).
        '';
        type    = nt.nullOr nt.str;
        default = null;
        example =
          "ca94d3639714672bbfd55f03521d3f56bb6a25479bd425da81faf21f13e1e9d1" +
          "5f40f97377dedbbf477a5841c5b0c8f4cd1b391f33553d750b9202c54c2c07aa";
      };


# ---------------------------------------------------------------------------- #

      languageName = lib.mkOption {
        description = lib.mdDoc ''
          May indicate which JavaScript runtime implementation a project is
          designed for.
          In practice this is almost always `node`.
        '';
        type    = nt.str;
        default = "node";
      };

      linkType = lib.mkOption {
        description = lib.mdDoc ''
          Whether `yarn` used "hard links" ( file copies ) or "soft links"
          ( symlinks ) to provide this package to consumers.

          NOTE: `floco` does not necessarily adhere to these settings.
        '';
        type    = nt.enum ["hard" "soft"];
        default = false;
      };


# ---------------------------------------------------------------------------- #

    };  # End `options'

  };  # End `ylent'

}  # End `types.nix'

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
