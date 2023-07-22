# -*- mode: sh; sh-shell: bash; -*-
# ============================================================================ #
#
# Overrides certain defaults and extends the Nixpkgs' `stdenv' builder.
#
#
# ---------------------------------------------------------------------------- #

# From `default-builder.sh'

if [ -f .attrs.sh ]; then
  #shellcheck disable=SC2091
  . .attrs.sh;
fi

source "${stdenv?}/setup";


# ---------------------------------------------------------------------------- #

# Enforce stricter shell evaluation.

set -o nounset;
set -o errexit;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# A commonly used routine to kill the `./node_modules' directory before
# "installing" a prepared package/module to `$out'.
# Provided as a function so that it can be overridden or disabled.
cleanupNmDir() {
  rm -f ./package-lock.json ./yarn.lock;
  if [[ -L ./node_modules ]]; then
    rm ./node_modules;
  elif [[ -d ./node_modules ]]; then
    rm -rf ./node_modules;
  fi
}


# ---------------------------------------------------------------------------- #

# Override the default `installCheckPhase' to accept a list of hooks.

#shellcheck disable=SC2034
declare -a preCheckHooks checkHooks postCheckHooks;

checkPhase() {
  runHook preCheck;
  runHook check;
  runHook postCheck;
}


# ---------------------------------------------------------------------------- #

# Override the default `installCheckPhase' to accept a list of hooks.

#shellcheck disable=SC2034
declare -a preInstallCheckHooks installCheckHooks postInstallCheckHooks;

installCheckPhase() {
  runHook preInstallCheck;
  runHook installCheck;
  runHook postInstallCheck;
}


# ---------------------------------------------------------------------------- #

# From `default-builder.sh'

genericBuild;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
