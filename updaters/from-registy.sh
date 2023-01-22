#! /usr/bin/env bash
# ============================================================================ #
#
# Generate a package from the `npm' registry including its full dep-graph.
# Dev. dependencies will be omitted from generated definitions.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

_as_me="floco update registry";

_version="0.1.0";

# [-c FLOCO-CONFIG-FILE]
_usage_msg="$_as_me IDENT[@DESCRIPTOR=latest] [-o PDEFS-FILE] [-- NPM-FLAGS...]

Generate a package from the \`npm' registry including its full dep-graph.
";

_help_msg="$_usage_msg

Dev. dependencies will be omitted from generated definitions.

OPTIONS
  -o,--out-file PATH  Path to write generated \`pdef' records.
                      Defaults to \`PWD/pdefs.nix'.
                      If the outfile already exists, it may be used to optimize
                      translation, and will be backed up to \`PDEFS-FILE~'.
  -c,--config PATH    Path to a \`floco' configuration file which may be used to
                      extend or modify the module definitions used to translate
                      and export \`pdef' records.
                      If no config is given default settings will be used.
  -j,--json           Export JSON instead of a Nix expression.
  -- NPM-FLAGS...     Used to separate \`$_as_me' flags from \`npm' flags.

ENVIRONMENT
  NIX           Command to use as \`nix' executable.
  NPM           Command to use as \`npm' executable.
  JQ            Command to use as \`jq' executable.
  SED           Command to use as \`sed' executable.
  REALPATH      Command to use as \`realpath' executable.
  MKTEMP        Command to use as \`mktemp' executable.
  FLOCO_CONFIG  Path to a \`floco' configuration file. Used as \`--config'.
  FLAKE_REF     Flake URI ref to use for \`floco'.
                defaults to \`github:aakropotkin/floco'.
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
: "${NIX:=nix}";
: "${NPM:=npm}";
: "${JQ:=jq}";
: "${REALPATH:=realpath}";
: "${SED:=sed}";
: "${MKTEMP:=mktemp}";


# ---------------------------------------------------------------------------- #

unset OUTFILE PKG;

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      while read -r -n1 opt; do
        if [[ -z "$opt" ]]; then
          break;
        fi
        _args+=( "-$opt" );
      done <<<"${_arg#-}";
      set -- "${_args[@]}" "$@";
      unset _arg _args;
      continue;
    ;;
    --*=*)
      _arg="$1";
      shift;
      set -- "${_arg%%=*}" "${_arg#*=}" "$@";
      unset _arg;
      continue;
    ;;
    -o|--out-file) OUTFILE="$( $REALPATH "$2"; )"; shift; ;;
    -c|--config)   FLOCO_CONFIG="$2"; shift; ;;
    -j|--json)     JSON=:; ;;
    -u|--usage)    usage;    exit 0; ;;
    -h|--help)     usage -f; exit 0; ;;
    -v|--version)  echo "$_version"; exit 0; ;;
    --) shift; break; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
    *)
      if [[ -z "${PKG:-}" ]]; then
        PKG="$1";
      else
        echo "$_as_me: Unexpected argument(s) '$*'" >&2;
        usage -f >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done

if [[ -n "${FLOCO_CONFIG:-}" ]]; then
  FLOCO_CONFIG="$( $REALPATH "$FLOCO_CONFIG"; )";
fi
: "${JSON=}";
: "${FLAKE_REF:=github:aakropotkin/floco}";
if [[ -z "${OUTFILE:-}" ]]; then
  if [[ -z "$JSON" ]]; then
    OUTFILE="$PWD/pdefs.nix";
  else
    OUTFILE="$PWD/pdefs.json";
  fi
fi


# ---------------------------------------------------------------------------- #

# Make relative flake ref absolute
case "$FLAKE_REF" in
  *:*) :; ;;
  .*|/*) FLAKE_REF="$( $REALPATH "$FLAKE_REF"; )"; ;;
  *)
    if [[ -r "$FLAKE_REF/flake.nix" ]]; then
      FLAKE_REF="$( $REALPATH "$FLAKE_REF"; )";
    fi
  ;;
esac


# ---------------------------------------------------------------------------- #

# Backup existing outfile if one exists
if [[ -r "$OUTFILE" ]]; then
  echo "$_as_me: backing up existing \`${OUTFILE##*/}' to \`$OUTFILE~'" >&2;
  cp -p -- "$OUTFILE" "$OUTFILE~";
fi


# ---------------------------------------------------------------------------- #

LOCKDIR="$( $MKTEMP -d; )";
pushd "$LOCKDIR" >/dev/null;

echo '{"name":"@floco/phony","version":"0.0.0-0"}' > ./package.json;

$NPM install            \
  --save                \
  --package-lock-only   \
  --ignore-scripts      \
  --lockfile-version=3  \
  --no-audit            \
  --no-fund             \
  --no-color            \
  --global-style        \
  "$@"                  \
  "$PKG"                \
;


# ---------------------------------------------------------------------------- #

cleanup() {
  popd >/dev/null;
  rm -rf "$LOCKDIR";
  if [[ "$_es" -ne 0 ]]; then
    rm -f "$OUTFILE";
  fi
}
_es=0;
trap '_es="$?"; cleanup; exit "$_es";' HUP TERM INT QUIT EXIT;


# ---------------------------------------------------------------------------- #

: "${FLOCO_CONFIG=}";
export FLAKE_REF FLOCO_CONFIG JSON OUTFILE;

if [[ -z "$JSON" ]]; then
  _NIX_FLAGS="--raw";
else
  _NIX_FLAGS="--json";
fi


# TODO: unstringize `fetchInfo' relative paths.
$NIX --no-substitute eval --show-trace $_NIX_FLAGS -f - <<'EOF' >"$OUTFILE"
let
  floco = builtins.getFlake ( builtins.getEnv "FLAKE_REF" );
  inherit (floco) lib;
  # TODO: use `old' and `cfg' as modules.
  #cfgPath = builtins.getEnv "FLOCO_CONFIG";
  #cfg     = if ( cfgPath != "" ) && ( builtins.pathExists cfgPath )
  #          then [cfgPath]
  #          else [];
  asJSON  = ( builtins.getEnv "JSON" ) != "";
  base = import "${floco}/modules/plockToPdefs/implementation.nix" {
    inherit lib;
    lockDir = toString ./.;
    plock   = lib.importJSON ./package-lock.json;
  };
  phony = builtins.head ( builtins.filter ( v:
    ( v.ident == "@floco/phony" ) && ( v.version == "0.0.0-0" )
  ) base.exports );
  target   = builtins.head ( builtins.attrNames phony.depInfo );
  ppath    = "node_modules/${target}";
  tver     = baseNameOf phony.treeInfo.${ppath}.key;
  pplen    = ( builtins.stringLength ppath ) + 1;
  treeInfo = let
    np    = removeAttrs phony.treeInfo [ppath];
    remap = p: {
      name  = builtins.substring pplen ( builtins.stringLength p ) p;
      value = np.${p};
    };
  in builtins.listToAttrs ( map remap ( builtins.attrNames np ) );
  parted = builtins.partition ( v:
    ( v.ident == target ) && ( v.version == tver )
  ) ( builtins.tail base.exports );
  injected = ( builtins.head parted.right ) // { inherit treeInfo; };
  pl2pdefs = [injected] ++ parted.wrong;
in if asJSON then pl2pdefs else lib.generators.toPretty {} pl2pdefs
EOF


# ---------------------------------------------------------------------------- #

# Nix doesn't quote some reserved keywords when dumping expressions, so we
# post-process a bit to add quotes.

if [[ -z "$JSON" ]]; then
  $SED -i 's/ \(assert\|with\|let\|in\|or\|inherit\|rec\) =/ "\1" =/'  \
          "$OUTFILE";
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
