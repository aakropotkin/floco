# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/packages/interface.nix";

# ---------------------------------------------------------------------------- #

  options.packages = lib.mkOption {

    description = lib.mdDoc ''
      Collection of built/prepared packages and modules.
    '';

    # NOTE: modifying the `getSubOptions' routine isn't working here.
    # I have no idea why but the issue is relatively benign since it only
    # effects documentation generation.
    # Nonetheless I'm leaving it until it can be properly debugged.
    type = let
      pkgType = nt.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [../package/interface.nix];
      };
    in nt.attrsOf ( nt.attrsOf pkgType );

    example.lodash."4.17.21".key = "lodash/4.17.21";

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
