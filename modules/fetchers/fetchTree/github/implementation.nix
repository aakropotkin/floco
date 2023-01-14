# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pure, ... }: {

  # TODO: get `narHash' as well
  config.github = lib.mkIf ( ! pure ) ( { config, ... }: {
    config.rev = lib.mkDefault ( builtins.fetchTree {
      type = "github";
      inherit (config) owner repo ref;
    } ).rev;
  } );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
