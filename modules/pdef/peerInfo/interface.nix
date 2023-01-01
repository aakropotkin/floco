# ============================================================================ #
#
# Information concerning `peerDependencies' or "propagated dependencies".
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options = {
    peerInfo = lib.mkOption {
      description = lib.literalMD ''
        Set of propogated dependencies that consumers of this package/module
        must provide at runtime.

        Often peer dependencies are used to enforce interface alignment across
        a set of modules but do not necessarily imply that the requestor depends
        on the declared peer at build time or runtime - rather it states
        "my consumers depend on the declared peer as a side effect of their
        dependence on me".
      '';
      type = nt.attrsOf ( nt.submoduleWith {
        modules = [./single.interface.nix];
      } );
      default = {};
    };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
