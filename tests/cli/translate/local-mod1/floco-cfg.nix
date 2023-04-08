# ============================================================================ #
#
# Aggregates configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
#
# ---------------------------------------------------------------------------- #

{
  imports = builtins.filter builtins.pathExists [
    ./pdefs.nix
    ./foverrides.nix
  ];
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
