{ pkgs, ... }: {
  config.floco.fetchers.fetchTree_tarball.function = {
    type    ? "tarball"
  , url
  , narHash ? ( builtins.fetchTree args ).narHash
  } @ args: let
    drv = pkgs.fetchzip {
      inherit url;
      outputHash     = narHash;
      outputHashAlgo = "sha256";
    };
  in drv // { inherit narHash; };
}
