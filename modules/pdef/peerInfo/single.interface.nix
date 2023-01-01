# ============================================================================ #
#
# Interface for a single `peerInfo' sub-record.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options = {
    descriptor = lib.mkOption {
      description = lib.mdDoc ''
        Descriptor indicating version range or exact source required to satisfy
        a peer dependency.

        The value `"*"` allows any version or source to be used, as long as it
        has the same identifier ( name ).
      '';
      type    = nt.str;
      default = "*";
    };
    optional = lib.mkOption {
      description = lib.mdDoc ''
        Whether consumers are required to provide the declared peer.

        Optional peer declarations are conventionally used to handle platform
        or architecture dependant modules which are only required for certain
        systems - in general this field should be interpreted as "this
        peer dependency is required under certain conditions".
        Often these conditions are audited using `postinstall` scripts, and as
        an optimization it may be worthwhile to ignore those audits if their
        conditions can be asserted in Nix ( for example if you know `system`,
        there's no reason to use a derivation to run some JavaScript that probes
        and audits `cpu` and `os` ).
      '';
      type    = nt.bool;
      default = false;
    };
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
