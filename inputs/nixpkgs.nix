let
  lock = builtins.fromJSON ( builtins.readFile ../flake.lock );
  nl   = lock.nodes.nixpkgs.locked;
  uri  = nl.type + ":" + nl.owner + "/" + nl.repo + "/" + nl.rev;
in {
  inherit uri;
  flake = builtins.getFlake uri;
  tree  = builtins.fetchTree nl;
}
