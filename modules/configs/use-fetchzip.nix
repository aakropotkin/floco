{ pkgs, ... }: {
  config.floco.fetchers.fetchTree_tarball.function = {
    type    ? "tarball"
  , url
  , narHash ? ( builtins.fetchTree args ).narHash
  } @ args: let
    base = pkgs.fetchzip {
      inherit url;
      outputHash     = narHash;
      outputHashAlgo = "sha256";
    };
    forLinux = base.overrideAttrs ( prev: {
      postFetch = ''
        unpackFile() {
          tar tf "$1"|xargs -i dirname '{}'|sort -u|xargs -i mkdir -p '{}';
          tar --no-same-owner --delay-directory-restore  \
              --no-same-permissions --no-overwrite-dir   \
              -xf "$1" --warning=no-timestamp;
        }
      '' + prev.postFetch;
    } );
    drv = if pkgs.stdenv.isLinux then forLinux else base;
  in drv // { inherit narHash; };
}
