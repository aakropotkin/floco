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

  options.rootTreeInfo = lib.mkOption {
    type = nt.lazyAttrsOf (
      nt.submodule ../records/pdef/treeInfo/single.interface.nix
    );
    default = {};
  };

  options.pdefsByPath = lib.mkOption {
    type    = nt.lazyAttrsOf ( nt.submodule {} );
    default = {};
  };

  options.exports = lib.mkOption {
    type    = nt.lazyAttrsOf ( nt.lazyAttrsOf lib.libfloco.jsonValue );
    default = {};
  };

  options.includePins  = lib.mkOption {
    description = lib.mdDoc ''
      Whether `<pdef>.depInfo` records should include pinned version info.

      NOTE: This may have undesired consequences in poorly authored projects
      which contain large numbers of ambiguous resolution conflicts.
      Specifically you should keep in mind that this makes it impossible for
      a package with multiple instances in a tree to resolve different versions
      of any of its dependencies.
      Frankly if a project breaks for this reason you should scrap whatever
      pile of garbage you're trying to package and use more sensibly
      designed alternative.
      Depending on ambiguous resolution between multiple instances is a
      violation of interface design, and if you file a bug report about it I'm
      going to make fun of you.

      See Also: includeRootTreeInfo
    '';
    default = false;
    type    = nt.bool;
  };

  options.includeRootTreeInfo = lib.mkOption {
    description = lib.mdDoc ''
      Whether `<pdef>.treeInfo` records should be included for the root project.

      This tree information will produce an exact replica of the `node_modules/`
      tree described by the lockfile, but may be less efficient than the
      symlinked `treeInfo` definitions that are derived from
      `<pdef>.depInfo.*.pin` information.

      You may prefer this option over `includePins` if your projects contain
      dependency cycles or rely on ambiguous resolution across multiple
      instances in the lock.
      If either of these cases effect your project you can enable this option,
      but I urge you to unfuck your dependency graph instead.
      Packages which rely on either resolution conflicts or dependency cycles
      fail to follow basic Software Development best practice, and should be
      reorganized/refactored in a sane manner.

      See Also: includePins
    '';
    default = true;
    type    = nt.bool;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
