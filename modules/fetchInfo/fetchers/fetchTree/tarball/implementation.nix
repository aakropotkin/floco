# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

  config.tarball = lib.mkIf ( ! config.pure ) ( { config, ... }: {
    config.narHash = lib.mkDefault ( builtins.fetchTree {
      type = "tarball";
      inherit (config) url;
    } ).narHash;
  } );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
