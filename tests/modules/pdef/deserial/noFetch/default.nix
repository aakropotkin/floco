# This test is a timebomb that will explode if any module attempts to fetch
# the source tree.
# This ensures that we are really just using the cached metadata.
let
  lib = import ../../../../../lib {};
  mod = lib.evalModules {
    modules = [./floco-cfg.nix];
  };
  kill = [
    "_module" "metaFiles" "sourceInfo" "fetcher"
  ];
  rsl = removeAttrs mod.config kill;
in builtins.deepSeq rsl true
