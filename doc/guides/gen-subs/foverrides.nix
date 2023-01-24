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
         ( ! ( test ".*\\.nix" bname ) ) &&
         ( ( type == "symlink" ) -> (
             ( bname != "result" ) && ( ! ( test "result-.*" bname ) )
           ) );
    };

    # CHANGEME: The following two blocks provide an example of dropping
    # `typescript' from the `node_modules/' directory of the `built' target,
    # and adding `typescript' as a globally installed package instead.
    # This strategy can be used to limit time spent copying files.

    # Remove `node_modules/typescript' since it will instead be accessed
    # using `PATH'.
    built.tree = let
      noTs = cfg.trees.dev.overrideAttrs ( prev: {
        keyTree = removeAttrs prev.keyTree ["node_modules/typescript"];
      } );
    in lib.mkIf ( cfg.treeInfo ? "node_modules/typescript" ) (
      lib.mkForce noTs
    );

    built.overrideAttrs = let
      ov = prev: {
        # Add `typescript' as a globally installed package.
        buildInputs = let
          tsVersion =
            baseNameOf cfg.pdef.treeInfo."node_modules/typescript".key;
        in prev.buildInputs ++ [
          config.floco.packages."typescript".${tsVersion}.global
        ];
      };
    in lib.mkIf ( cfg.treeInfo ? "node_modules/typescript" ) (
      lib.mkForce ov
    );

  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
