# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;
  ft = import ../pdef/types.nix { inherit lib; };

in {

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    key = lib.mkOption {
      description = ''
        Unique key used to refer to this package in `tree' submodules and other
        `floco' configs, metadata, and structures.
      '';
      type = ft.key;
    };


# ---------------------------------------------------------------------------- #

    pkgdef = lib.mkOption {
      description = ''
        Package's declared metadata normalized as `pdef' submodule.
      '';
      type = nt.submoduleWith { modules = [../pdef]; };
    };


# ---------------------------------------------------------------------------- #

    source = lib.mkOption {
      description = ''
        Unpacked source tree used as the basis for package/module preparation.

        It is strongly recommended that you use `config.pkgdef.sourceInfo' here
        unless you are intentionally applying patches, filters, or your package
        resides in a subdir of `sourceInfo'.

        XXX: This tree should NOT patch shebangs yet, since this would deprive
        builders which produce distributable tarballs or otherwise "un-nixify" a
        module of an "unpatched" point of reference to work with.
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

    built = lib.mkOption {
      description = ''
        "Built" form of a package/module which is ready for distribution as a
        tarball ( `build' and `prepublish' scripts must be run if defined ).

        By default the `dev' tree is used for this stage.

        If no build is required then this option is an alias of `source'.

        XXX: If a `build' script produces executable scripts you should NOT
        patch shebangs yet - patching should be deferred to the
        `prepared' stage.
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

    installed = lib.mkOption {
      description = ''
        "Installed" form of a package/module which is ready consumption as a
        module in a `node_modules/' directory, or global installation for use
        as a package.

        This stage requires that any `install' scripts have been run, which
        conventionally means "run `node-gyp' to perform system dependant
        compilation or setup".

        By default the `prod' tree is used for this stage.

        If no install is required then this option is an alias of `built'.

        XXX: If an `install' script produces executable scripts you should NOT
        patch shebangs yet - patching should be deferred to the
        `prepared' stage.
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

    prepared = lib.mkOption {
      description = ''
        Fully prepared form of package/module tree making it ready for
        consumption as either a globally installed package, or module under a
        `node_modules/' tree.

        Generally this option is an alias of a previous stage; but this also
        provides a useful opportunity to explicitly define additional
        post-processing routines that don't use default `built' or `installed'
        stage builders ( for example, setting executable bits or applying
        shebang patches to scripts ).
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
