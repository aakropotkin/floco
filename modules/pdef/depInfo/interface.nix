# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options.depInfo = lib.mkOption {
    description = ''
      Information regarding dependency modules/packages.
      This record is analogous to the various
      `package.json:.[dev|peer|optional|bundled]Dependencies[Meta]' fields.

      These config settings do note necessarily dictate the contents of the
      `trees' configs, which are used by builders, but may be used to provide
      information needed to generate trees if they are not defined.
    '';
    type = nt.attrsOf ( nt.submoduleWith {
      modules = [./single.interface.nix];
    } );
    default = {};
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
