# ============================================================================ #
#
# Types associated with individual `package-lock.json:.packages.*' entries.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  plent = nt.submodule {

# ---------------------------------------------------------------------------- #

    freeformType = nt.attrsOf nt.anything;

    options = {

# ---------------------------------------------------------------------------- #

      key     = lib.mkKeyOption;
      ident   = lib.mkIdentOption;
      version = lib.mkVersionOption;


# ---------------------------------------------------------------------------- #

      requires = lib.mkOption {
        type    = nt.either ( nt.attrsOf nt.str ) nt.bool;
        default = {};
      };

      dependencies         = lib.mkDepAttrsOption;
      devDependencies      = lib.mkDepAttrsOption;
      devDependenciesMeta  = lib.mkDepMetasOption;
      peerDependencies     = lib.mkDepAttrsOption;
      peerDependenciesMeta = lib.mkDepMetasOption;
      optionalDependencies = lib.mkDepAttrsOption;

      dev      = lib.mkOption { type = nt.bool; default = false; };
      optional = lib.mkOption { type = nt.bool; default = false; };
      peer     = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

      os  = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
      cpu = lib.mkOption { type = nt.listOf nt.str; default = ["*"]; };
      # In the lockfile this can also be a list of strings as:
      #   ["node >= 8.0.0"]
      # Which is fucking infuriating but whatever.
      # We normalize it in our implementation.
      engines = lib.mkOption {
        type    = nt.attrsOf nt.str;
        default = {};
        example = { node = ">=8.0.0"; };
      };


# ---------------------------------------------------------------------------- #

      bin = lib.mkOption {
        description = lib.mdDoc ''
          Pairs of `{ <NAME> = <REL-PATH>; ... }` indicating executables that
          will installed, and their associated source code to be symlinked.

          These can be used "as is" to set `<PKG-ENT>.binInfo.binPairs`.
        '';
        type    = nt.attrsOf nt.str;
        default = {};
        example = { "semver" = "bin/semver.js"; };
      };


# ---------------------------------------------------------------------------- #

      resolved = lib.mkOption {
        type    = nt.str;
        default = ".";
        example = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
      };

      integrity = lib.mkOption {
        description = "SHA integrity hash for tarball. Usually a sha512.";
        type        = nt.nullOr nt.str;
        default     = null;
        example     =
          "sha512-/3IjMdb2L9QbBdWiW5e3P2/" +
          "npwMBaU9mHCSCUzNln0ZCYbcfTsGbTJrU/kGemdH2IWmB2ioZ+zkxtmq6g09fGQ==";
      };

      sha1 = lib.mkOption {
        description = lib.mdDoc ''
          SHA1 hash for tarball.
          This field may exist if another integrity hash was already provided
          in the `integrity` field.
          It is not strictly specified whether the value need be an SRI, but I
          have never found a non SRI hash in a lockfile produced after NPM v8.
        '';
        type    = nt.nullOr nt.str;
        default = null;
        example = "sha1-J1hIEIkUVqQXHI0CJkQa3pDLyus=";
      };


# ---------------------------------------------------------------------------- #

      link = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

      hasInstallScript = lib.mkOption { type = nt.bool; default = false; };
      gypfile          = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

    };  # End `options'

  };  # End `plent'

}  # End `types.nix'

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
