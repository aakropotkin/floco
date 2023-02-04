# ============================================================================ #
#
# Aggregates configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
#
# ---------------------------------------------------------------------------- #

{ ... }: {
  imports = let
    ifExist = builtins.filter builtins.pathExists [
      ./pdefs.nix       # Generated `pdefs.nix'
      ./foverrides.nix  # Explicit config
    ];
  in ifExist ++ [
    # CHANGEME: If you depend on other `floco' projects, you can import their
    # `floco-cfg.nix' files here to make those configs available.
  ];

  config.floco.buildPlan.deriveTreeInfo = true;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
