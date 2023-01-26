{ lib, ... }: {
  imports = [
    ../../../../modules/pdef/deserialize.nix
    ../../../../modules/pdef
    {
      ident     = "lodash";
      version   = "4.17.21";
      ltype     = "file";
      fetchInfo = {
        type    = "tarball";
        url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
      };
      treeInfo   = {};
      sourceInfo = throw "This shouldn't be referenced";
    }
  ];
}
