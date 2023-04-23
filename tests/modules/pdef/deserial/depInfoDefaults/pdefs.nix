{
  # Show that deserialized form of this sets `dev = true;' ( the default ) for
  # omitted fields.
  floco.pdefs."@floco/phony"."4.2.0" = {
    ident     = "@floco/phony";
    version   = "4.2.0";
    ltype     = "file";
    fetchInfo = {
      type    = "tarball";
      url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
      narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
    };
    treeInfo = {};
    depInfo  = {
      lodash = {
        descriptor = "^4.17.21";
        pin        = "4.17.21";
        runtime    = true;
      };
    };
  };
}
