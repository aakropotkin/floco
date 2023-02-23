# ============================================================================ #
#
# This is the "standard" for of a `pjsCore' record which summarizes "manifest"
# fields found in `package.json' and similar files.
#
# This has been added as a `lib' member because of how common it is used in
# extensions and custom translators.
#
# This implementation is the default used by `floco.records.pjsCore' which was
# intentionally exposed as an overridable/extensible record in the
# module system.
#
# For anyone who needs to extend this record to perform preprocessing or other
# fixup during `translation' routines in modules - you will likely want to
# "include" this record as a base or at least align your record with this
# core collection of fields.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  pjsCoreDeferred = ./submodule.nix;

  pjsCore = nt.submodule pjsCoreDeferred;


# ---------------------------------------------------------------------------- #

in {

  inherit
    pjsCoreDeferred
    pjsCore
  ;

  mkPjsCoreOption = lib.mkOption {
    description = lib.mdDoc ''
      Project "manifest" information like those found in
      `package.json` and similar files, extended with `floco` specific
      "core" information such as `key` and `ident`.
    '';
    type = pjsCore;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
