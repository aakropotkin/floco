# ============================================================================ #
#
# Aggregates configs making them available to `default.nix', `flake.nix',
# or other projects that want to consume this module/package as a dependency.
#
# ---------------------------------------------------------------------------- #

{
  imports = let
    maybePdefs =
      if builtins.pathExists ./pdefs.nix  then [./pdefs.nix] else
      if builtins.pathExists ./pdefs.json then [{
        _file  = ./pdefs.json;
        config = let
          c = builtins.fromJSON ( builtins.readFile ./pdefs.json );
        in c.config or c;
      }] else [];
    maybeFoverrides =
      if builtins.pathExists ./foverrides.nix  then [./foverrides.nix] else
      if builtins.pathExists ./foverrides.json then [{
        _file  = ./foverrides.json;
        config = let
          c = builtins.fromJSON ( builtins.readFile ./foverrides.json );
        in c.config or c;
      }] else [];
  in maybePdefs ++ maybeFoverrides ++ [
    # CHANGEME: If you depend on other `floco' projects, you can import their
    # `floco-cfg.nix' files here to make those configs available.
  ];

  # CHANGEME: If your project doesn't have dependency cycles, and you have
  # `<pdef>.depInfo.*.pin' records, you can enable symlinked trees with:
  ## config.floco.buildPlan.deriveTreeInfo = true;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
