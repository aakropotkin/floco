# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/plock/plent/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    link             = lib.mkOption { type = nt.bool; default = false; };
    hasInstallScript = lib.mkOption { type = nt.bool; default = false; };
    gypfile          = lib.mkOption { type = nt.bool; default = false; };

# ---------------------------------------------------------------------------- #

    requires = lib.mkOption {
      type    = nt.either ( nt.attrsOf nt.str ) nt.bool;
      default = {};
    };

    dev      = lib.mkOption { type = nt.bool; default = false; };
    optional = lib.mkOption { type = nt.bool; default = false; };
    peer     = lib.mkOption { type = nt.bool; default = false; };


# ---------------------------------------------------------------------------- #

    bundleDependencies = lib.mkOption {
      type    = nt.either nt.bool ( nt.listOf nt.str );
      default = {};
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

    funding = lib.mkOption {
      type    = nt.listOf ( nt.lazyAttrsOf lib.jsonValue );
      default = [];
    };

    license = lib.mkOption {
      type    = nt.nullOr nt.str;
      default = null;
    };


# ---------------------------------------------------------------------------- #

  };  # End `options'

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
