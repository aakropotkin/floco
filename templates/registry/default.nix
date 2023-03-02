# ============================================================================ #
#
# Package shim exposing installable targets from `floco' modules.
#
# ---------------------------------------------------------------------------- #

{ floco        ? builtins.getFlake "github:aakropotkin/floco"
, lib          ? floco.lib
, system       ? builtins.currentSystem
, extraModules ? []
}: let

# ---------------------------------------------------------------------------- #

  inherit (import ./info.nix) ident version;

# ---------------------------------------------------------------------------- #

  fmod = lib.evalModules {
    modules = [
      floco.nixosModules.floco
      { config.floco.settings = { inherit system; }; }
      ./floco-cfg.nix
    ] ++ ( lib.toList extraModules );
  };


# ---------------------------------------------------------------------------- #

  # This attrset holds a few derivations related to our package.
  # We'll only expose `global' to the CLI.
in fmod.config.floco.packages.${ident}.${version}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
