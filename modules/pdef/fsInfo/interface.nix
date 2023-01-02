# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.fsInfo = lib.mkOption {

    description = ''
      Indicates information about a package that must be scraped from its
      source tree, rather than a conventional config file.

      It is not recommended for users to manually fill these fields; rather
      we expect these to be informed by a cache or lockfile.
      You're welcome to explicitly define them, but I don't want to see anyone
      griping about these options in bug reports.
    '';

    default = { gypfile = false; shrinkwrap = false; dir = "."; };

# ---------------------------------------------------------------------------- #

    type = nt.submodule {

      options.gypfile = lib.mkOption {
        description = lib.mdDoc ''
          Whether `binding.gyp` exists in the project root.
          May be explicitly overridden by declarations in `package.json`.

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

      options.shrinkwrap = lib.mkOption {
        description = lib.mdDoc ''
          Whether `npm-shrinkwrap.json` exists in the project root.
          This is distributed form of `package-lock.json` which may be used to
          install exact dependencies during global installation of packages.
          For module/workspace installation this file takes precedence over
          `package-lock.json` if it exists.

          The use of `npm-shrinkwrap.json` is only recommended for executables.

          NOTE: `floco` does not use `npm-shrinkwrap.json` at this time, so this
          field exists as a stub.
        '';
        type    = nt.bool;
        default = false;
      };

      options.dir = lib.mkOption {
        description = lib.mdDoc ''
          Relative path from `sourceInfo.outPath` to the package's root.
          This field is analogous to a flake input's `dir` field, and is
          used in combination with `fetchInfo` in exactly the same way as
          a flake input.

          You should almost never need to set this field for distributed
          tarballs ( only if it contains bundled dependencies ).

          While this field is useful for working with monorepos I strongly
          recommend that you avoid abusing it.
          Its use inherently causes rebuilds of all projects in associated
          with a single `sourceInfo` record for any change in the subtree.
          It is much more efficient to split a subtree into multiple sources,
          but I've left you enough rope to learn things the hard way if you
          insist on doing so.
          Consider yourself warned.
        '';
        type    = nt.str;
        default = ".";
      };

    };  # End `options.fsInfo.type.options'


# ---------------------------------------------------------------------------- #

  };  # End `options.fsInfo'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
