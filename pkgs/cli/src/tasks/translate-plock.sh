#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${_as_main=floco}";
_as_sub='translate plock';
_as_me="$_as_main $_as_sub";

: "${_version:=0.1.1}";

_usage_msg="Usage: $_as_me [OPTIONS...] [-o PDEFS-FILE] [-- NPM-FLAGS...]

Create or update a \`pdefs.nix' file using a \`package-lock.json' v3 provided
by \`npm'.
";

_help_msg="$_usage_msg

This script will trash any existing \`node_modules/' trees, and if a
\`package-lock.json' file already exists, it will be backed up and restored
on exit to ensure that it is unmodified by this script.

Options:
  -t,--tree           Include \`treeInfo' for the root package.
  -T,--no-tree        Omit \`treeInfo' for the root package.
  -p,--pins           Include \`<pdef>.depInfo.*.pin' info.
  -P,--no-pins        Omit \`<pdef>.depInfo.*.pin' info.
  -d,--debug          Show \`nix' backtraces.
  -l,--lock-dir PATH  Path to directory containing \`package[-lock].json'.
                      This directory must contain a \`package.json', but need
                      not
                      contain a \`package-lock.json'.
                      Defaults to current working directory.
  -o,--out-file PATH  Path to write generated \`pdef' records.
                      Defaults to \`<LOCK-DIR>/pdefs.nix'.
                      If the outfile already exists, it may be used to optimize
                      translation, and will be backed up to \`PDEFS-FILE~'.
  -j,--json           Export JSON instead of a Nix expression.
  -B,--no-backup      Remove backups of \`PDEFS-FILE' when process succeeds.
  -c,--config PATH    Path to a \`floco' configuration file which may be used to
                      extend or modify the module definitions used to translate
                      and export \`pdef' records.
                      If no config is given default settings will be used.
  -- NPM-FLAGS...     Used to separate \`$_as_me' flags from \`npm' flags.

Environment:
  NIX           Command used as \`nix' executable.
  NPM           Command used as \`npm' executable.
  JQ            Command used as \`jq' executable.
  REALPATH      Command used as \`realpath' executable.
  FLOCO_CONFIG  Path to a \`floco' configuration file. Used as \`--config'.
  FLOCO_REF     Flake URI ref to use for \`floco'.
                defaults to \`github:aakropotkin/floco'.
  DEBUG         Show \`nix' backtraces.
";


# ---------------------------------------------------------------------------- #

usage() {
  if [[ "${1:-}" = "-f" ]]; then
    echo "$_help_msg";
  else
    echo "$_usage_msg";
  fi
}


# ---------------------------------------------------------------------------- #

# @BEGIN_INJECT_UTILS@
: "${GREP:=grep}";
: "${REALPATH:=realpath}";
: "${MKTEMP:=mktemp}";
: "${NIX:=nix}";
: "${NPM:=npm}";
: "${JQ:=jq}";
export GREP REALPATH MKTEMP NIX NPM JQ;


# ---------------------------------------------------------------------------- #

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      _i=1;
      while [[ "$_i" -lt "${#_arg}" ]]; do
        _args+=( "-${_arg:$_i:1}" );
        _i="$(( _i + 1 ))";
      done
      set -- "${_args[@]}" "$@";
      unset _arg _args _i;
      continue;
    ;;
    --*=*)
      _arg="$1";
      shift;
      set -- "${_arg%%=*}" "${_arg#*=}" "$@";
      unset _arg;
      continue;
    ;;
    -o|--out-file|--outfile)
      if [[ "$2" = '-' ]]; then
        OUTFILE='/dev/stdout';
      else
        OUTFILE="$( $REALPATH "$2"; )";
      fi
      shift;
    ;;
    -t|--tree)                              TREE=:; ;;
    -T|--no-tree|--notree)                  TREE=; ;;
    -p|--pins|--pin)                        PINS=:; ;;
    -P|--no-pins|--no-pin|--nopins|--nopin) PINS=; ;;
    -d|--debug)                             DEBUG=:; ;;
    -l|--lock-dir|--lockdir) LOCKDIR="$( $REALPATH "$2"; )"; shift; ;;
    -B|--no-backup)          NO_BACKUP=:; ;;
    -c|--config)             FLOCO_CONFIG="$2"; shift; ;;
    -j|--json)               JSON=:; ;;
    -u|--usage)              usage;    exit 0; ;;
    -h|--help)               usage -f; exit 0; ;;
    -v|--version)            echo "$_version"; exit 0; ;;
    --)                      shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      echo "$_as_me: Unexpected argument(s) '$*'" >&2;
      usage -f >&2;
      exit 1;
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

: "${FLOCO_LIBDIR:=$( $REALPATH "${BASH_SOURCE[0]%/*}/../lib"; )}";
export FLOCO_LIBDIR;


# ---------------------------------------------------------------------------- #

# Load common helpers

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../lib/dirs.sh
. "$FLOCO_LIBDIR/dirs.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../lib/common.sh
. "$FLOCO_LIBDIR/common.sh";

#shellcheck source-path=SCRIPTDIR
#shellcheck source=../lib/fmt.sh
. "$FLOCO_LIBDIR/fmt.sh";


# ---------------------------------------------------------------------------- #

if [[ -n "${FLOCO_CONFIG:-}" ]]; then
  _l_floco_cfg="$( $REALPATH "$FLOCO_CONFIG"; )";
  export _l_floco_cfg;
fi

if [[ -n "${FLOCO_REF:-}" ]]; then
  # Make relative flake ref absolute
  case "$FLOCO_REF" in
    *:*) :; ;;
    .*|/*) FLOCO_REF="$( $REALPATH "$FLOCO_REF"; )"; ;;
    *)
      if [[ -r "$FLOCO_REF/flake.nix" ]]; then
        FLOCO_REF="$( $REALPATH "$FLOCO_REF"; )";
      fi
    ;;
  esac
  export _floco_ref="$FLOCO_REF";
else
  FLOCO_REF="$( flocoRef; )";
fi

: "${LOCKDIR:=$PWD}";
: "${JSON=}";
: "${NO_BACKUP=}";
: "${TREE=:}";
: "${PINS=}";
: "${DEBUG=}";


if [[ -z "${OUTFILE:-}" ]]; then
  if [[ -z "$JSON" ]]; then
    OUTFILE="$LOCKDIR/pdefs.nix";
  else
    OUTFILE="$LOCKDIR/pdefs.json";
  fi
fi


# ---------------------------------------------------------------------------- #

declare -a oldFiles;
oldFiles=();

for f in {pdefs,foverrides}.{nix,json}; do
  if [[ -r "$LOCKDIR/$f" ]]; then
    oldFiles+=( "$LOCKDIR/$f~" );
    if [[ "$OUTFILE" = "$LOCKDIR/$f" ]]; then
      echo "$_as_me: Backing up existing \`${OUTFILE##*/}' to \`$OUTFILE~'" >&2;
      cp -p -- "$OUTFILE" "$OUTFILE~";
    else
      echo "$_as_me: Stashing file to avoid conflicts: \`$LOCKDIR/$f'" >&2;
      mv -- "$LOCKDIR/$f" "$LOCKDIR/$f~";
      echo '{}' > "$LOCKDIR/$f";
    fi
  fi
done


# ---------------------------------------------------------------------------- #

# Lint target package for stuff that will trip up attempts to generate `pdefs'.
if [[ "$( $JQ -r '.name // null' "$LOCKDIR/package.json"; )" = 'null' ]]; then
  echo "$_as_me: target package is unnamed. name it you dingus." >&2;
  exit 1;
fi

if [[ "$( $JQ -r '.version // null' "$LOCKDIR/package.json"; )" = 'null' ]];
then
  echo "$_as_me: target package is unversioned. version it you dangus." >&2;
  exit 1;
fi


# ---------------------------------------------------------------------------- #

# Backup existing lockfile if one exists
if [[ -r "$LOCKDIR/package-lock.json" ]]; then
  printf '%s' "$_as_me: backup up existing \`package-lock.json' to "  \
              "\`$LOCKDIR/package-lock.json~'" >&2;
  echo '' >&2;
  cp -p -- "$LOCKDIR/package-lock.json" "$LOCKDIR/package-lock.json~";
fi


# ---------------------------------------------------------------------------- #

if [[ -d "$LOCKDIR/node_modules" ]]; then
  echo "$_as_me: deleting \`$LOCKDIR/node_modules' to avoid pollution" >&2;
  rm -rf "$LOCKDIR/node_modules";
fi


# ---------------------------------------------------------------------------- #

pushd "$LOCKDIR" >/dev/null;


# ---------------------------------------------------------------------------- #

cleanup() {
  if [[ -r "$LOCKDIR/package-lock.json~" ]]; then
    echo "$_as_me: Restoring original \`package-lock.json'." >&2;
    mv -- "$LOCKDIR/package-lock.json~" "$LOCKDIR/package-lock.json";
  else
    rm -f "$LOCKDIR/package-lock.json";
  fi
  if [[ ( -n "$NO_BACKUP" ) && ( -r "$OUTFILE~" ) ]]; then
    echo "$_as_me: Deleting backup \`$OUTFILE'." >&2;
    rm -f "$OUTFILE~";
  fi
  for o in "${oldFiles[@]}"; do
    if [[ "${o%\~}" = "$OUTFILE" ]]; then
      continue;
    fi
    if [[ -r "$o" ]]; then
      echo "$_as_me: Restoring stashed file \`${o%\~}'." >&2;
      mv -- "$o" "${o%\~}";
    fi
  done
}

bail() {
  echo "$_as_me: Encountered an error. Restoring backup files." >&2;
  if [[ "$OUTFILE" != '/dev/stdout' ]]; then rm -f "$OUTFILE"; fi
  if [[ -r "$OUTFILE~" ]]; then
    echo "$_as_me: Restoring backup \`$OUTFILE'." >&2;
    mv -- "$OUTFILE~" "$OUTFILE";
  fi
  if [[ -n "${PINS:-}" ]]; then
    echo "$_as_me: If translation failed due to infinite recursion, you may \
have dependency cycles in your lockfile.
  While we truly recommend unfucking your dependency graph, and following good \
Software Development best practices.
  We understand that you probably just want to build your project, so try \
rerunning this script using the \`--tree --no-pins' flags.
  This produces a ( significantly ) slower build plan, but if you care about \
performance you should follow best practices.
  Refactor with sensible interface design to kill cycles, or file PRs/bug \
reports for external dependencies." >&2;
  fi
  cleanup;
}

_es=0;
trap '_es="$?"; bail; exit "$_es";' HUP TERM INT QUIT;
trap '
_es="$?";
if [[ "$_es" -ne 0 ]]; then
  bail;
else
  cleanup;
fi
exit "$_es";
' EXIT;


# ---------------------------------------------------------------------------- #

{
  $NPM install            \
    --package-lock-only   \
    --ignore-scripts      \
    --lockfile-version=3  \
    --no-audit            \
    --no-fund             \
    --no-color            \
    "$@"                  \
  ;
} >&2;


# ---------------------------------------------------------------------------- #

export OUTFILE JSON PINS TREE LOCKDIR FLOCO_REF;

_NIX_FLAGS=();

if [[ -z "$JSON" ]]; then
  _NIX_FLAGS+=( "--raw" );
else
  _NIX_FLAGS+=( "--json" );
fi

if [[ -n "$DEBUG" ]]; then
  _NIX_FLAGS+=( "--show-trace" );
fi

#shellcheck disable=SC2119
mktmpAuto;
OUTFILE_TMP="$_tmpAuto";

#shellcheck disable=SC2153
flocoEval                           \
  --no-substitute                   \
  "${_NIX_FLAGS[@]}"                \
  --apply 'f: f {}'                 \
  -f "$FLOCO_NIXDIR/fromPlock.nix"  \
  > "$OUTFILE_TMP"                  \
;


# ---------------------------------------------------------------------------- #

# Nix doesn't quote some reserved keywords when dumping expressions, so we
# post-process a bit to add quotes.

if [[ -z "$JSON" ]]; then
  _nix_keyword_escape "$OUTFILE_TMP" > "$OUTFILE";
else
  $JQ . "$OUTFILE_TMP" > "$OUTFILE";
fi


# ---------------------------------------------------------------------------- #



# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
