# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

    metaFiles.vinfoUrl = lib.mkDefault (
      if config.ltype != "file" then null else
      "https://registry.npmjs.org/${config.ident}/${config.version}"
    );

    metaFiles.vinfoHash = lib.mkDefault (
      if config.metaFiles.vinfoUrl == null then null else
      ( builtins.fetchTree {
        type = "file";
        url  = config.metaFiles.vinfoUrl;
      } ).narHash
    );

    metaFiles.vinfo = let
      fetched = builtins.fetchTree {
        type    = "file";
        url     = config.metaFiles.vinfoUrl;
        narHash = config.metaFiles.vinfoHash;
      };
      attrs = lib.importJSON fetched;
    in lib.mkDefault (
      if config.metaFiles.vinfoUrl != null then attrs else null
    );


# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/vinfo/implementation.nix";

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
