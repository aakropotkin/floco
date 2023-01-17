# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

    metaFiles.packumentUrl = lib.mkDefault (
      if config.ltype != "file" then null else
      "https://registry.npmjs.org/${config.ident}"
    );

    metaFiles.packumentHash = lib.mkDefault (
      if config.metaFiles.packumentUrl == null then null else
      ( builtins.fetchTree {
        type = "file";
        url  = config.metaFiles.packumentUrl;
      } ).narHash
    );

    metaFiles.packument = let
      fetched = builtins.fetchTree {
        type    = "file";
        url     = config.metaFiles.packumentUrl;
        narHash = config.metaFiles.packumentHash;
      };
      attrs = lib.importJSON fetched;
    in lib.mkDefault (
      if config.metaFiles.packumentUrl != null then attrs else null
    );

    metaFiles.packumentRev =
      if config.metaFiles.packument == null then null else
      config.metaFiles.packument._rev or null;


# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/packument/implementation.nix";

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
