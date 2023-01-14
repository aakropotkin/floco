# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pure, ... }: {

  # TODO: get `narHash' as well
  config.git = lib.mkIf ( ! pure ) ( { config, ... }: {
    config.rev = lib.mkDefault ( builtins.fetchTree {
      type = "git";
      inherit (config) url allRefs shallow submodules ref;
    } ).rev;
  } );

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
