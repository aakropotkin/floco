# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  lock = lib.importJSON ../../flake.lock;

# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/inputs/implementation.default.nix";

  config.inputs.nixpkgs = {
    inherit (lock.nodes.nixpkgs) locked;
    id    = "nixpkgs";
    uri   = "github:NixOS/nixpkgs/" + config.inputs.nixpkgs.locked.rev;
    tree  = builtins.fetchTree config.inputs.nixpkgs.locked;
    flake = builtins.getFlake (
      builtins.unsafeDiscardStringContext config.inputs.nixpkgs.tree.outPath
    );
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
