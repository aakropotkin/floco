# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs       ? ( import ../../inputs ).nixpkgs.flake
, lib           ? nixpkgs.lib
, system        ? builtins.currentSystem
, pkgsFor       ? nixpkgs.legacyPackages.${system}
, makeSetupHook ? pkgsFor.makeSetupHook
, jq            ? pkgsFor.jq
}: let

# ---------------------------------------------------------------------------- #

  # Join all hooks into a single file.
  # This really demands that each hook be written in such a way that only
  # function definitions and appends to hook lists are defined at the top level.
  joined = let
    hooks = [
      ./run-pjs-script.sh
      ./add-nmdir.sh
      ./set-node-path.sh
    ];
    contents = map builtins.readFile hooks;
    body     = builtins.concatStringsSep "\n" contents;
  in builtins.toFile "joined-hooks.sh" body;


# ---------------------------------------------------------------------------- #

in makeSetupHook {
  name = "floco-hooks";
  substitutions.jq = lib.getBin jq;
} joined


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
