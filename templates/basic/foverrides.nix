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

# ---------------------------------------------------------------------------- #

  config.floco.packages.${ident}.${version} = let
    cfg = config.floco.packages.${ident}.${version};
  in {  # Begin target package overrides

# ---------------------------------------------------------------------------- #

    # Removes any `*.nix' files as well as `node_modules/' and
    # `package-lock.json' from the source tree before using them in builds.
    source = lib.libfloco.cleanLocalSource ./.;


# ---------------------------------------------------------------------------- #

    # CHANGEME: The following two blocks provide an example of dropping
    # `typescript' from the `node_modules/' directory of the `built' target,
    # and adding `typescript' as a globally installed package instead.
    # This strategy can be used to limit time spent copying files.

    # The use of `lib.mkIf' causes this override to be applied only if your
    # target package depends on `typescript'; as an optimization you can
    # remove the conditional or remove this block entirely.

    # Remove `node_modules/typescript' since it will instead be accessed
    # using `PATH'.
    built.tree = let
      noTs = cfg.trees.dev.overrideAttrs ( prev: {
        treeInfo = removeAttrs prev.treeInfo ["node_modules/typescript"];
      } );
    in lib.mkIf ( cfg.trees.supported ? "node_modules/typescript" ) (
      lib.mkForce noTs
    );

    built.extraBuildInputs = let
      tsVersion =
        baseNameOf cfg.pdef.trees.supported."node_modules/typescript".key;
    in lib.mkIf ( cfg.treeInfo ? "node_modules/typescript" ) [
      config.floco.packages.typescript.${tsVersion}.global
    ];


# ---------------------------------------------------------------------------- #

  };  # End target package overrides


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
