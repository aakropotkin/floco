{ lib }: let
  proc = acc: f: acc // ( import f { inherit lib; } );
in builtins.foldl' proc {} [
  ./edge.nix ./overrides.nix ./node.nix
]
