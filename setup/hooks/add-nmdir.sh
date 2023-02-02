# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# This setup hook copies/symlinks a `node_modules/' directory into the build
# area ( at `$PWD/node_modules' ).
#
#
# ---------------------------------------------------------------------------- #

addNmDir() {
  local _from;

  [[ -z "${NMTREE:-}" ]] && return 0;

  if [[ -e ./node_modules ]]; then
    echo "addNmDir(): ERROR: node_modules directory already exists." >&2;
    return 1;
  fi

  if [[ -d "$NMTREE/node_modules" ]]; then
    _from="$NMTREE/node_modules";
  elif [[ -d "$NMTREE/lib/node_modules" ]]; then
    _from="$NMTREE/lib/node_modules";
  else
    _from="$NMTREE";
  fi

  if [[ "${copyTree:-0}" -ne 1 ]]; then
    ln -s -T -- "$_from" ./node_modules;
  else
    cp -r --reflink=auto -T -- "$_from" ./node_modules;
    chmod -R +w ./node_modules;
  fi

  if [[ -d ./node_modules/.bin ]]; then
    addToSearchPath PATH "$PWD/node_modules/.bin";
  fi
}

preConfigureHooks+=( addNmDir );


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
