# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/packument/interface.nix";

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    packument = lib.mkOption {
      description = ''
        Raw contents from a package registry concerning all published
        versions of a package/module.

        See Also: packumentUrl, vinfo
      '';
      type    = nt.nullOr ( nt.attrsOf nt.anything );
      default = null;
    };


# ---------------------------------------------------------------------------- #

    packumentUrl = lib.mkOption {
      description = lib.mdDoc ''
        Registry URL where "packument" information can be fetched.
        A packument contains information about all published versions of
        a package, and is commonly used to resolve package `descriptors`
        such as `^1.0.0` to a version such as `1.2.3`.

        This field is optional and may be set to `null` to avoid looking
        up projects which are not published to a registry, or to avoid
        processing packument metadata.

        NOTE: Processing packument metadata is not required when another
        form metadata such as `treeInfo` or `depInfo` is available for
        `floco` to construct a `node_modules/` tree with.
        Packuments are most useful for extensions to `floco` to perform
        tasks like auto-updating projects when new versions are published.
      '';
      type    = nt.nullOr nt.str;
      default = null;
      example = "https://registry.npmjs.org/lodash";
    };


# ---------------------------------------------------------------------------- #

    packumentHash = lib.mkOption {
      description = lib.mdDoc ''
        SHA256 hash used to lock and purify fetching of
        packument metadata.
        In practice you likely want to automate updates to this hash since
        it will be invalidated every time a new version of a package is
        published to the registry.

        To lock onto a specific version of a package you may find that the
        `vinfo` metadata is better suited for locking.

        See Also: packumentUrl, packumentRev, vinfoUrl
      '';
      type    = nt.nullOr nt.str;
      default = null;
    };


# ---------------------------------------------------------------------------- #

    packumentRev = lib.mkOption {
      description = lib.mdDoc ''
        Revision information associated with a packument.
        In combination with `packumentHash` this value could potentially
        be used to immitate a Nix input's lockfile entry.

        This revision information is provided under the `_rev` field of
        a packument, and is formatted as `<REV-COUNT>-<COMMITISH-HASH>`.

        NOTE: At time of writing this field is unused, but future
        extensions to `floco` intend to use this field to write packument
        information to `flake.lock`.
      '';
      type    = nt.nullOr nt.str;
      default = null;
      example = "2722-2d3b98d05acf18018581dd0b19bc2bfc";
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
