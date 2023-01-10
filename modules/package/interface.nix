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

  imports = [./trees/interface.nix ./targets/interface.nix];

# ---------------------------------------------------------------------------- #

  options = {

# ---------------------------------------------------------------------------- #

    key = lib.mkOption {
      description = lib.mdDoc ''
        Unique key used to refer to this package in `tree` submodules and other
        `floco` configs, metadata, and structures.
      '';
      type    = ft.key;
      example = "@floco/test/4.2.0";
    };


# ---------------------------------------------------------------------------- #

    pdef = lib.mkOption {
      description = lib.mdDoc ''
        Package's declared metadata normalized as `pdef` submodule.
      '';
      type = nt.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [../pdef/interface.nix];
      };
    };


# ---------------------------------------------------------------------------- #

    checkSystemSupport = lib.mkOption {
      description = lib.mdDoc ''
        A function that checks if `stdenv.hostPlatform` or a `system` pair can
        support a package.
        This uses translated `sysInfo` records.
      '';
      default = {
        stdenv   ? throw "checkSystemSupport: You must pass an arg"
      , platform ? stdenv.hostPlatform
      , system   ? platform.system
      }: true;
      type    = nt.functionTo nt.bool;
      example = lib.literalExpression ''
        checkSystemSupport = {
          stdenv   ? throw "checkSystemSupport: You must pass an arg"
        , platform ? stdenv.hostPlatform
        , system   ? platform.system
        }: ( builtins.match "x86_64-*" system ) != null;
      '';
    };


# ---------------------------------------------------------------------------- #

    systemSupported = lib.mkOption {
      description = lib.mdDoc ''
        Indicates whether this package/module is supported
        by `config.pkgs.stdenv.hostPlatform`.
        This value is the result of evaluating `config.checkSystemSupported`
        against `config._module.args.pkgs`.
      '';
      type     = nt.bool;
      internal = true;
    };


# ---------------------------------------------------------------------------- #

    installed = lib.mkOption {
      description = lib.mdDoc ''
        "Installed" form of a package/module which is ready consumption as a
        module in a `node_modules/` directory, or global installation for use
        as a package.

        This stage requires that any `install` scripts have been run, which
        conventionally means "run `node-gyp` to perform system dependant
        compilation or setup".

        By default the `prod` tree is used for this stage.

        If no install is required then this option is an alias of `built`.

        XXX: If an `install` script produces executable scripts you should NOT
        patch shebangs yet - patching should be deferred to the
        `prepared` stage.
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

    prepared = lib.mkOption {
      description = lib.mdDoc ''
        Fully prepared form of package/module tree making it ready for
        consumption as either a globally installed package, or module under a
        `node_modules/` tree.

        Generally this option is an alias of a previous stage; but this also
        provides a useful opportunity to explicitly define additional
        post-processing routines that don't use default `built` or `installed`
        stage builders ( for example, setting executable bits or applying
        shebang patches to scripts ).
      '';
      type = nt.package;
    };


# ---------------------------------------------------------------------------- #

    global = lib.mkOption {
      description = lib.mdDoc ''
        Globally installed form of a package which uses conventional `POSIX`
        installation prefixes such as `lib/node_modules/` and `bin/`.

        Globally installed packages will carry their full runtime dependency
        tree as a subdir, allowing executables to resolve any necessary modules,
        and symlinks into other `node_modules/` directories to behave as they
        would with other Node.js package management tools.

        NOTE: If a project has dependency cycles it may be necessary to enable
        the option `preferMultipleOutputDerivations` to allow any `build` or
        `install` stages to run.
      '';
      type = nt.nullOr nt.package;
    };


# ---------------------------------------------------------------------------- #

    preferMultipleOutputDerivations = lib.mkOption {
      description = lib.mdDoc ''
        Whether builders should prefer preparing sources with a single multiple
        output derivation vs. multiple single output derivations.

        Setting this to `false` is sometimes useful for breaking dependency
        cycles for `global` packages or to intentionally introduce additional
        cache breakpoints in projects with excessively long `build` or `install`
        phases ( this may avoid rebuilds for certain types of changes to the
        dependency graph ).

        In general it is faster to use multiple output derivations, since most
        Node.js lifecycle stages execute relatively quickly, and splitting them
        requires a full sandbox to be created for each stage.
      '';
      default = false;
    };


# ---------------------------------------------------------------------------- #

    dist = lib.mkOption {
      description = lib.mdDoc ''
        Produce a distributable tarball suitable for publishing using the
        `built` form of a package.

        This target should never be enabled for packages whose `source` is
        already a registry tarball ( those with `ltype` of `file` ).

        The contents of this tarball will attempt to unpatch scripts using the
        original `source` package's contents - but if you produce any
        executables during your build it is your responsibility to ensure that
        they remain unpatched ( patching should be performed later during the
        `prepare` event instead ).

        TODO: This needs to unpatch shebangs.
      '';
      type    = nt.nullOr nt.package;
      default = null;
    };


# ---------------------------------------------------------------------------- #

    test = lib.mkOption {
      description = lib.mdDoc ''
        Run tests against the `built` form of a package.
        By default this executes any `test` scripts defined in `package.json`
        using the `dev` tree.

        As an optimization you may explicitly define `treeInfo.test` allowing
        `treeInfo.dev` to be reduced to the subset of dependencies required to
        build, and `treeInfo.test` to be reduced to the subset of dependencies
        required to run tests.
        This approach is STRONGLY encouraged especially if you use `jest`,
        `webpack`, or `babel` since these packages' all fail to properly
        adhere to Node.js resolution specifications for symlinks, and often
        require you to copy a massive pile of files into the sandbox.

        This target should never be enabled for packages/modules whose source
        was a distributed tarball ( those with `ltype` or `file` ) since these
        have already been tested as a part of their pre-release process.

        See Also: lint
      '';
      type    = nt.nullOr nt.package;
      default = null;
    };


# ---------------------------------------------------------------------------- #

    installDependsOnTest = lib.mkOption {
      description = lib.mdDoc ''
        Causes the `installed` lifecycle stage to be blocked by successful
        `test` checking ( required `test` to be non-null ).

        This is recommended for projects which are under active development.

        If `preferMultipleOutputDerivations` is enabled this is implemented by
        making the `test` derivation an input of the `installed` derivation.
        Otherwise this will cause a phase to run `test` checks before `install`
        events, killing the builder if the check fails.

        NOTE: if `installed` is an alias of `built`, this causes either
        `prepared` to depend on `test` instead.

        See Also: test, buildDependsOnLint
      '';
      type    = nt.bool;
      default = false;
    };


# ---------------------------------------------------------------------------- #

    lint = lib.mkOption {
      description = lib.mdDoc ''
        Run lints against the `source` of a package.
        By default this executes any `lint` scripts defined in `package.json`
        using the `dev` tree.

        As an optimization you may explicitly define `treeInfo.lint` allowing
        `treeInfo.dev` to be reduced to the subset of dependencies required to
        build, and `treeInfo.lint` to be reduced to the subset of dependencies
        required to run lints.
        This approach is STRONGLY encouraged especially if you use `jest`,
        `webpack`, or `babel` since these packages' all fail to properly
        adhere to Node.js resolution specifications for symlinks, and often
        require you to copy a massive pile of files into the sandbox.

        This target should never be enabled for packages/modules whose source
        was a distributed tarball ( those with `ltype` or `file` ) since these
        have already been linted as a part of their pre-release process.

        See Also: test
      '';
      type    = nt.nullOr nt.package;
      default = null;
    };


# ---------------------------------------------------------------------------- #

    warnings = lib.mkOption {
      description = ''
        List of warnings to be emitted when derivations are evaluated.
      '';
      type     = nt.listOf nt.str;
      default  = [];
      internal = true;
      visible  = false;
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
