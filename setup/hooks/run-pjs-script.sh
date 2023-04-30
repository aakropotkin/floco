# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# This is a minimal form of `run-script.sh' optimized for use in derivations.
#
# ---------------------------------------------------------------------------- #

runPjsScript() {
  local _body;
  case "$1" in
    -i|--ignore-missing)    IGNORE_MISSING=:; shift; ;;
    -I|--no-ignore-missing) IGNORE_MISSING=; shift; ;;
    *) :; ;;
  esac
  #shellcheck disable=SC2016
  _body="$(
    @jq@/bin/jq -r --arg sname "$1" '.scripts[$sname] // null' ./package.json;
  )";
  if [[ "$_body" = 'null' ]]; then
    if [[ -z "${IGNORE_MISSING:-}" ]]; then
      echo "runPjsScript(): ERROR: script \`$1' is undefined." >&2;
      return 1;
    fi
    return 0;
  fi
  # TODO: set `npm_config_*' vars
  eval "$_body";
}

runPjsScripts() {
  declare -a _opts;
  declare -a _scripts;
  _opts=();
  _scripts=();
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -*) _opts+=( "$1" ); ;;
      *)  _scripts+=( "$1" ); ;;
    esac
    shift;
  done
  for s in "${_scripts[@]}"; do
    runPjsScript "${_opts[@]}" "$s";
  done
}

npm() {
  case "$1" in
    run) runPjsScript "$2"; ;;
    *)   command npm "$@"; ;;
  esac
}

yarn() {
  case "$1" in
    run)   runPjsScript "$2"; ;;
    build) runPjsScripts prebuild build postbuild prepublish; ;;
    *)     command yarn "$@"; ;;
  esac
}



# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
