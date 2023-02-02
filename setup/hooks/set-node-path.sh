# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# This setup hook adds every build inputs' `lib/node_modules/' directory
# to `NODE_PATH'
#
# ---------------------------------------------------------------------------- #

export NODE_PATH;

addPkgToNodePath() {
  if [[ -d "$1/lib/node_modules" ]]; then
    addToSearchPath NODE_PATH "$1/lib/node_modules";
  fi
}

addEnvHooks "$hostOffset" addPkgToNodePath;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
