# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? builtins.getFlake "nixpkgs"
, lib     ? nixpkgs.lib
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, options
}: import "${nixpkgs}/nixos/lib/make-options-doc" {
  inherit lib;
  pkgs    = pkgsFor;
  options = removeAttrs options ["_module"];
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
