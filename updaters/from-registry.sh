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

#_as_me="floco update registry";
_as_me='from-registry.sh';

_version="0.4.0";

# [-c FLOCO-CONFIG-FILE]
_usage_msg="Usage: \
$_as_me [OPTIONS...] IDENT[@DESCRIPTOR=latest] [-o PDEFS-FILE] [-- NPM-FLAGS...]

Generate a package from the \`npm' registry including its full dep-graph.
";

_help_msg="$_usage_msg

Dev. dependencies will be omitted from generated definitions.

Options:
  -t,--tree           Include \`treeInfo' for the root package.
  -T,--no-tree        Omit \`treeInfo' for the root package.
  -p,--pins           Include \`<pdef>.depInfo.*.pin' info.
  -P,--no-pins        Omit \`<pdef>.depInfo.*.pin' info.
  -o,--out-file PATH  Path to write generated \`pdef' records.
                      Defaults to \`PWD/pdefs.nix'.
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
  SED           Command used as \`sed' executable.
  REALPATH      Command used as \`realpath' executable.
  MKTEMP        Command used as \`mktemp' executable.
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
    -t|--tree)                              TREE=:; ;;
    -T|--no-tree|--notree)                  TREE=; ;;
    -p|--pins|--pin)                        PINS=:; ;;
    -P|--no-pins|--no-pin|--nopins|--nopin) PINS=; ;;
    -o|--out-file|--outfile) OUTFILE="$( $REALPATH "$2"; )"; shift; ;;
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
: "${NO_BACKUP=}";
: "${FLAKE_REF:=github:aakropotkin/floco}";
: "${TREE=}";
: "${PINS=:}";

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

case "$( $NPM --version; )" in
  9.*) STRATEGY_FLAG='--install-strategy=shallow'; ;;
  *)   STRATEGY_FLAG='--global-style'; ;;
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


# ---------------------------------------------------------------------------- #

cleanup() {
  popd >/dev/null;
  rm -rf "$LOCKDIR";
  if [[ ( -n "$NO_BACKUP" ) && ( -r "$OUTFILE~" ) ]]; then
    echo "$_as_me: Deleting backup \`$OUTFILE'." >&2;
    rm -f "$OUTFILE~";
  fi
}

bail() {
  echo "$_as_me: Encountered an error. Restoring backup files." >&2;
  rm -f "$OUTFILE";
  if [[ -r "$OUTFILE~" ]]; then
    echo "$_as_me: Restoring backup \`$OUTFILE'." >&2;
    mv -- "$OUTFILE~" "$OUTFILE";
  fi
  if [[ -z "${TREE:-}" ]]; then
    echo "$_as_me: If translation failed due to infinite recursion, you may have
dependency cycles in your lockfile.
While we truly recommend unfucking your dependency graph, and following good
Software Development best practices.
We understand that you probably just want to build your project, so try
rerunning this script using the \`--tree' flag.
This produces a ( significantly ) slower build plan, but if you care about
performance you should follow best practices, and refactor with sensible
interface design to kill all cycles." >&2;
  fi
  cleanup;
}

_es=0;
trap '_es="$?"; bail; exit "$_es";' HUP TERM INT QUIT;
trap '_es="$?"; cleanup; exit "$_es";' EXIT;


# ---------------------------------------------------------------------------- #

echo '{"name":"@floco/phony","version":"0.0.0-0"}' > ./package.json;

$NPM install            \
  --save                \
  --package-lock-only   \
  --ignore-scripts      \
  --lockfile-version=3  \
  --no-audit            \
  --no-fund             \
  --no-color            \
  "$STRATEGY_FLAG"      \
  "$@"                  \
  "$PKG"                \
;


# ---------------------------------------------------------------------------- #

: "${FLOCO_CONFIG=}";
export FLAKE_REF LOCKDIR FLOCO_CONFIG JSON OUTFILE PINS TREE;

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
  cfgPath = builtins.getEnv "FLOCO_CONFIG";
  cfg =
    if ( cfgPath == "" ) || ( ! ( builtins.pathExists cfgPath ) ) then [] else
    if ( builtins.match ".*\\.json" cfgPath ) == null then [cfgPath] else
    [( lib.modules.importJSON cfgPath )];
  outfile = builtins.getEnv "OUTFILE";
  asJSON  = ( builtins.getEnv "JSON" ) != "";
  mod = lib.evalModules {
    modules = cfg ++ [
      floco.nixosModules.floco
      {
        options.floco = lib.mkOption {
          type = lib.types.submoduleWith {
            shorthandOnlyDefinesConfig = false;
            modules = [{
              imports = ["${floco}/modules/plockToPdefs"];
              config._module.args.basedir = /. + ( dirOf outfile );
              config.lockDir = /. + ( builtins.getEnv "LOCKDIR" );
              config.includePins         = ( builtins.getEnv "PINS" ) != "";
              config.includeRootTreeInfo = ( builtins.getEnv "TREE" ) != "";
            }];
          };
        };
      }
    ];
  };
  base     = mod.config.floco.exports;
  phony    = base."@floco/phony"."0.0.0-0";
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
  contents.floco.pdefs = ( removeAttrs base ["@floco/phony"] ) // {
    ${target} = base.${target} // {
      ${tver} = base.${target}.${tver} // { inherit treeInfo; };
    };
  };
in if asJSON then contents else lib.generators.toPretty {} contents
EOF


# ---------------------------------------------------------------------------- #

# Nix doesn't quote some reserved keywords when dumping expressions, so we
# post-process a bit to add quotes.

if [[ -z "$JSON" ]]; then
  $SED -i 's/ \(assert\|throw\|with\|let\|in\|or\|inherit\|rec\) =/ "\1" =/'  \
          "$OUTFILE";
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
