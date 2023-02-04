# ============================================================================ #
#
# Aggregates configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {
  imports = let
    tryImports = builtins.filter builtins.pathExists [
      # Loads generated `pdefs.nix' as a "module config".
      ./pdefs.nix

      # Explicit config
      ./foverrides.nix
    ];
  in tryImports ++ [
    # CHANGEME: If you depend on other `floco' projects, you can import their
    # `floco-cfg.nix' files here to make those configs available.
  ];
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
