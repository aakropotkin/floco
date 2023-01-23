# ============================================================================ #
#
# Aggregates configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: {
  imports = [
    # Loads generated `pdefs.nix' as a "module config".
    ( lib.addPdefs ./pdefs.nix )

    # Explicit config
    ./foverrides.nix

    # CHANGEME: If you depend on other `floco' projects, you can import their
    # `floco-cfg.nix' files here to make those configs available.
  ];
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
