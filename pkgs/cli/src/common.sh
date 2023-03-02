#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

if [[ -n "${_floco_cli_common_sourced:-}" ]]; then
  return 0;
fi


# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${GREP:=grep}";
: "${HEAD:=head}";
: "${JQ:=jq}";
: "${MKTEMP:=mktemp}";
: "${NIX:=nix}";
: "${REALPATH:=realpath}";

export GREP HEAD JQ MKTEMP NIX REALPATH;


# ---------------------------------------------------------------------------- #

if [[ "${#BASH_SOURCE[@]}" -gt 1 ]]; then
  SPATH="$( $REALPATH "${BASH_SOURCE[1]}"; )";
else
  SPATH="$PWD/interactive";
fi

SDIR="${SPATH%/*}";
_as_me="${SPATH##*/}";

export SPATH SDIR _as_me;


# ---------------------------------------------------------------------------- #

# stopSearch DIR
# --------------
# Return 0 if DIR's parent is searchable, 1 otherwise.
keepSearching() {
  ! { [[ "$( $REALPATH "$1"; )" = '/' ]] || [[ -d "$1/.git" ]]; };
}

# searchUp FILE [DIR]
# -------------------
searchUp() {
  if [[ -r "${2:-$PWD}/$1" ]]; then
    $REALPATH "${2:-$PWD}/$1";
  elif keepSearching "${2:-$PWD}"; then
    searchUp "$1" "${2:-$PWD}/..";
  else
    return 1;
  fi
}


# ---------------------------------------------------------------------------- #

# Set the var `_g_floco_cfg' to the "global" floco config file if it exists.
if [[ -z "${_g_floco_cfg+y}" ]]; then
  if [[ -r /etc/floco/floco-cfg.nix ]]; then
    export _g_floco_cfg='/etc/floco/floco-cfg.nix';
  elif [[ -r /etc/floco/floco-cfg.json ]]; then
    export _g_floco_cfg='/etc/floco/floco-cfg.json';
  else
    export _g_floco_cfg=;
  fi
fi


# ---------------------------------------------------------------------------- #

# Set the var `_u_floco_cfg' to the "user" floco config file if it exists.
: "${XDG_CONFIG_HOME:=${HOME:-/homeless/shelter}/.config}";
export XDG_CONFIG_HOME;

if [[ -z "${_u_floco_cfg+y}" ]]; then
  if [[ -r $XDG_CONFIG_HOME/floco/floco-cfg.nix ]]; then
    export _u_floco_cfg="$XDG_CONFIG_HOME/floco/floco-cfg.nix";
  elif [[ -r $XDG_CONFIG_HOME/floco/floco-cfg.json ]]; then
    export _u_floco_cfg="$XDG_CONFIG_HOME/floco/floco-cfg.json";
  else
    export _u_floco_cfg=;
  fi
fi


# ---------------------------------------------------------------------------- #

: "${_l_floco_cfg=}";
export _l_floco_cfg;

# Lazily locate the closest `floco-cfg.{json,nix}' between `PWD' and the closest
# repository root, or filesystem root.
localFlocoCfg() {
  if [[ -z "${_l_floco_cfg:=$( searchUp floco-cfg.nix||:; )}" ]]; then
    unset _floco_cfg;
    if [[ -z "${_l_floco_cfg:=$( searchUp floco-cfg.json||:; )}" ]]; then
      echo "$_as_me: no floco-cfg.nix or floco-cfg.json found" >&2;
      return 1;
    fi
  fi
  echo "$_l_floco_cfg";
}


# ---------------------------------------------------------------------------- #

# Print all the floco config files that are "in scope".
flocoCfgFiles() {
  if [[ -n "$_g_floco_cfg" ]]; then echo "$_g_floco_cfg"; fi
  if [[ -n "$_u_floco_cfg" ]]; then echo "$_u_floco_cfg"; fi
  {
    if [[ -n "$( localFlocoCfg||:; )" ]]; then echo "$_l_floco_cfg"; fi
  } 2>/dev/null;
}


# ---------------------------------------------------------------------------- #

# Try to find a flake ref to `floco' by searching in `flake.lock' files, and
# `nix registry'.
: "${_floco_ref=}";
export _floco_ref;

flocoRef() {
  : "${_floco_ref=}";
  if [[ -n "$_floco_ref" ]]; then
    echo "$_floco_ref";
    return 0;
  fi

  local flock;
  if [[ -n "${flock=$( searchUp flake.lock||:; )}" ]]; then
    if $JQ -e '.nodes|has("floco")' "$flock" >/dev/null; then
      #shellcheck disable=SC2016
      _floco_ref="$( $JQ -r '
.nodes.floco.locked as $locked|
if $locked.type == "path" then
  "path:" + $locked.path
else
  if $locked.type == "github" then
    "github:" + $locked.owner + "/" + $locked.repo + "/" + $locked.rev
  else
    if $locked.url|test( "narHash=" ) then
      $locked.type + $locked.url
    else
      if $locked.url|test( "\\?" ) then
        $locked.type + $locked.url + "&narHash=" + $locked.narHash
      else
        $locked.type + $locked.url + "?narHash=" + $locked.narHash
      end
    end
  end
end
' "$flock"; )";
      echo "$_floco_ref";
      return 0;
    fi
  fi
  _floco_ref="$(
    {
      { $NIX registry list|$GREP ' flake:floco '; }               \
        || echo 'fallback flake:floco github:aakropotkin/floco';
    }|$HEAD -n1;
  )";
  _floco_ref="${_floco_ref##* }";

  echo "$_floco_ref";
}


# ---------------------------------------------------------------------------- #

# Records the running system pair as recognized by `nix CMD --system SYSTEM'.
: "${_nix_system=}";
export _nix_system;

nixSystem() {
  if [[ -z "$_nix_system" ]]; then
    _nix_system="$( $NIX eval --raw --impure --expr builtins.currentSystem; )";
  fi
  echo "$_nix_system";
}


# ---------------------------------------------------------------------------- #

flocoCmd() {
  local _cmd _dir _old_l_floco_cfg;
  _cmd="$1";
  shift;

  _old_l_floco_cfg="$( localFlocoCfg 2>/dev/null||:; )";
  unset _l_floco_cfg;

  if [[ "$#" -gt 0 ]] && [[ -d "$1" ]]; then
    _dir="$1";
    shift;
  else
    _dir="$PWD";
  fi

  $NIX "$_cmd" -f "${BASH_SOURCE[0]%/*}/common.nix"          \
    --argstr system    "$( nixSystem; )"                     \
    --argstr flocoRef  "$( flocoRef; )"                      \
    --argstr globalCfg "$_g_floco_cfg"                       \
    --argstr userCfg   "$_u_floco_cfg"                       \
    --argstr localCfg  "$( localFlocoCfg 2>/dev/null||:; )"  \
    "$@"                                                     \
  ;

  _l_floco_cfg="$_old_l_floco_cfg";
}


# ---------------------------------------------------------------------------- #

flocoEval()  { flocoCmd eval "$@"; }
flocoBuild() { flocoCmd build "$@"; }


# ---------------------------------------------------------------------------- #

declare -a _tmp_files _tmp_dirs;
_tmp_files=();
_tmp_dirs=();
export _tmp_files _tmp_dirs;

mktmpAuto() {
  local _f;
  _f="$( $MKTEMP "$@"; )";
  case " $* " in
    *\ -d\ *|*\ --directory\ *) _tmp_dirs+=( "$_f" ); ;;
    *)                          _tmp_files+=( "$_f" ); ;;
  esac
  echo "$_f";
}


# ---------------------------------------------------------------------------- #

commonCleanup() {
  rm -f "${_tmp_files[@]}";
  rm -rf "${_tmp_dirs[@]}";
}

declare -a cleanupHooks;
cleanupHooks=( commonCleanup );
export cleanupHooks;

cleanup() {
  local _hook;
  for _hook in "${cleanupHooks[@]}"; do
    "$_hook";
  done
}


_es=0;
trap '
_es="$?";
cleanup;
exit "$_es";
' HUP TERM INT QUIT EXIT;


# ---------------------------------------------------------------------------- #

helpUrls() {
  echo "Report bugs to: <https://github.com/aakropotkin/floco/issues>";
  echo "floco home page: <https://github.com/aakropotkin/floco>";
  echo "Matrix chat support room: \
<https://matrix.to/#/!tBPFHeGmZfhbuYgvcw:matrix.org?via=matrix.org>";
}


# ---------------------------------------------------------------------------- #

# XXX: You must NOT export this variable, since subcommands will
# not be passed definitions of functions defined here.
_floco_cli_common_sourced=:;


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
