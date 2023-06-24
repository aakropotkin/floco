# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, pkgs, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/settings/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.settings.system = lib.mkDefault (
    builtins.currentSystem or "unknown"
  );

# ---------------------------------------------------------------------------- #

  # Try to use `nodejs-14_x', then `nodejs-16_x', falling back to `nodejs'.
  # If the package is missing or marked as unavailable ( usually resulting from
  # a users `nixpkgs.config.permittedInsecurePackages' setting ).
  config.settings.nodePackage = let
    # If a package is marked as available use it, otherwise fall back to a
    # second option.
    ifAvailableOr = attrName: fallback: let
      a = builtins.getAttr attrName pkgs;
    in if ! ( builtins.hasAttr attrName pkgs )   then fallback else
       if ( ( a.meta or {} ).available or true ) then a        else fallback;
  in lib.mkDefault (
    ifAvailableOr "nodejs-14_x" ( ifAvailableOr "nodejs-16_x" pkgs.nodejs )
  );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
