# ============================================================================ #
#
# Serializes a `depInfo' record to prepare for writing to a file.
#
# `depInfo' is returned as a member of an attrset that can be merged with other
# export data.
# This allows `depInfo' to be omitted entirely if there are no dependencies.
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  defaultEntry = {
    # descriptor  = "*";  # Always preserve
    pin         = null;
    optional    = false;
    bundled     = false;
    runtime     = false;
    dev         = true;
    devOptional = false;
  };

  dropDefaults = entry: lib.filterAttrs ( k: v:
    ( ! ( defaultEntry ? ${k} ) ) || ( v != defaultEntry.${k} )
  ) entry;


# ---------------------------------------------------------------------------- #

in depInfo: if depInfo == {} then {} else {
  depInfo = lib.mapAttrs ( name: entry: dropDefaults entry ) depInfo;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
