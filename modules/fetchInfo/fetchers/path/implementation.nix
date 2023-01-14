# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: {

  config.path = lib.mkIf ( ! config.pure ) ( { config, ... }: {
    config.sha256 = lib.mkDefault ( builtins.fetchTree {
      type = "path";
      path = builtins.path { inherit (config) name path filter recursive; };
    } ).narHash;
  } );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
