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
, bash    ? pkgsFor.bash
}: let

# ---------------------------------------------------------------------------- #

  # docbook, html, markdown, org
  formats = import ./formats.nix {
    inherit nixpkgs lib system pkgsFor pandoc bash;
  };

  options = import ./options.nix { inherit nixpkgs lib system pkgsFor; };


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
