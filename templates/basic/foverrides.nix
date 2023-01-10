# ============================================================================ #
#
# Explicit config and overrides.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  pjs   = lib.importJSON ./package.json;
  ident = pjs.name;
  inherit (pjs) version;

# ---------------------------------------------------------------------------- #

in {
  # Removes any `*.nix' files as well as `node_modules/' and
  # `package-lock.json' from the source tree before using them in builds.
  config.floco.packages.${ident}.${version} = let
    cfg = config.floco.packages.${ident}.${version};
  in {
    source = builtins.path {
      name   = "source";
      path   = ./.;
      filter = name: type: let
        bname  = baseNameOf name;
        test   = p: s: ( builtins.match p s ) != null;
        ignore = ["node_modules" "package-lock.json"];
      in ( ! ( builtins.elem bname ignore ) ) &&
          ( ! ( test ".*\\.nix" bname ) );
    };
    # FIXME: This adds a copy of `typescript' to the "build" environment
    # as a globally installed executable.
    # This allows `typescript' to be dropped from your `node_modules/'
    # directory in order to speed up builds.
    # You can remove or modify this block as you see fit.
    built.tree = removeAttrs cfg.trees.dev ["node_modules/typescript"];
    built.overrideAttrs =
      lib.mkIf ( cfg.trees.dev ? "node_modules/typescript" ) ( prev: {
        buildInputs = let
          tsVersion = baseNameOf cfg.trees.dev."node_modules/typescript";
        in prev.buildInputs ++ [
          config.floco.packages."typescript".${tsVersion}.global
        ];
      } );
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
