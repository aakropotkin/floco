# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, pandoc  ? pkgsFor.pandoc
}: let

# ---------------------------------------------------------------------------- #

  # docbook, html, markdown, org
  formats = import ./formats.nix {
    inherit nixpkgs lib system pkgsFor pandoc;
  };

  options = import ./options.nix { inherit lib; };


# ---------------------------------------------------------------------------- #

in builtins.mapAttrs ( _: f: f {
  bname = "floco-modules";
  inherit options;
} ) formats


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
