# Aggregates our configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
{
  imports = [
    # Loads our generated `pdefs.nix' as a "module config".
    ( lib.addPdefs ./pdefs.nix )
    # Explicit config
    ./foverrides.nix
  ];
}
