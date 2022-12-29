#! /usr/bin/env bash
# ============================================================================ #
#
# Install a prepared module to a `node_modules/' path without
# handling dependencies.
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;

# ---------------------------------------------------------------------------- #

_as_me='floco install-module';

_usage_msg="
install-module.sh [OPTIONS] FROM NM-DIR

Module rooted at \`FROM' ( as \`FROM/package.json' ), will be installed to
\`NM-DIR/<NAME>' symlinking any executables to \`NM-DIR/.bin'.
";

_help_msg="
$_usage_msg

OPTIONS
  -t,--to         Treat \`NM-DIR' as literal install dir as \`node_modules/foo'
  -i,--ident ID   Treat \`ID' as the package identifier/name
  -b,--bins       Force processing of bins
  -B,--no-bins    Skip processing bins
  -p,--perms      Force fixing of \`FROM' permissions for +wrx dirs, and +x bins
  -P,--no-perms   Skip checking of \`FROM' permissions, copy them \"as is\"
  -s,--patch      Force patching shebangs
  -S,--no-patch   Skip patching shebangs
  -u,--usage      Print usage message to STDOUT
  -h,--help       Print this message to STDOUT

ENVIRONMENT
The following environment variables may be used unless explicitly overridden by
options/flags mentioned above.
These variables are not required, but may be used as an optimization to skip
reading the contents of \`package.json'.

Variables marked as \"Bool\" are treated as false when unset or set to the empty
string, or true for any non-empty value.

  IDENT       Treat \`IDENT' as the package identifier/name.
  NO_BINS     Skip processing of bins if non-empty. ( Bool )
  BIN_PAIRS   Space separated tuples of executables to be installed as:
              \`BIN-NAME,REL-PATH BIN-NAME2,REL-PATH...\'
  BIN_DIR     Relative path to directory containing scripts to be installed as
              executables ( drops any extension for exposed bin ).
              This variable is ignored if \`BIN_PAIRS' is non-empty.
  NO_PERMS    Skip checking/fixup of directory and executable permissions
              when non-empty. ( Bool )
  NO_PATCH    Skip patching shebangs in scripts when non-empty. ( Bool )
  NODEJS      Absolute path to \`node' executable.
              May be omitted if patching shebangs is disabled.
  JQ          Absolute path to \`jq' executable. ( Optional )
              May be omitted if \`IDENT' is known and any \`*BIN*' variable is
              is non-empty ( it is only needed to read \`package.json' ).
  ID          Absolute path to \`id' executable.    ( Optional )
  CHMOD       Absolute path to \`chmod' executable. ( Optional )
  CHOWN       Absolute path to \`chown' executable. ( Optional )
  MKDIR       Absolute path to \`mkdir' executable. ( Optional )
  CP          Absolute path to \`cp' executable.    ( Optional )
              This is useful for adding additional flags or wrapping the
              program used to copy files.
  LN          Absolute path to \`ln' executable.       ( Optional )
  REALPATH    Absolute path to \`realpath' executable. ( Optional )
  FIND        Absolute path to \`find' executable.     ( Optional )
  BASH        Absolute path to \`bash' executable.     ( Optional )
";


# ---------------------------------------------------------------------------- #

usage() {
  echo "$_usage_msg";
  [[ "${1:-}" = "-f" ]] && echo "$_help_msg";
}


# ---------------------------------------------------------------------------- #

: "${JQ:=jq}";
: "${CHMOD:=chmod}";
: "${CHOWN:=chown}";
: "${MKDIR:=mkdir}";
: "${CP:=cp}";
: "${REALPATH:=realpath}";
: "${FIND:=find}";
: "${LN:=ln}";
: "${BASH:=bash}";
: "${ID:=id}";

unset FROM NMDIR TO NM_IS_TO;

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    # Split short options such as `-abc' -> `-a -b -c'
    -[^-]?*)
      _arg="$1";
      declare -a _args;
      _args=();
      shift;
      while read -r -N1 opt; do
        _args+=( "-$opt" );
      done <<<"${_arg#-}";
      set -- "${_args[@]}" "$@";
      unset _arg _args;
      continue;
    ;;
    -t|--to)       NM_IS_TO=:; ;;
    -i|--ident)    IDENT="$1"; shift; ;;
    -b|--bins)     NO_BINS=''; ;;
    -B|--no-bins)  NO_BINS=:; unset BIN_PAIRS BIN_DIR; ;;
    -p|--perms)    NO_PERMS=''; ;;
    -P|--no-perms) NO_PERMS=:; unset CHMOD; ;;
    -s|--patch)    NO_PATCH=''; ;;
    -S|--no-patch) NO_PATCH=:; unset NODEJS; ;;
    -u|--usage)    usage;    exit 0; ;;
    -h|--help)     usage -f; exit 0; ;;
    *)
      if [[ -z "${FROM:-}" ]]; then
        FROM="$( $REALPATH -m "$1"; )";
      elif [[ -z "${NMDIR:-}" ]]; then
        NMDIR="$( $REALPATH -m "$1"; )";
      else
        echo "$_as_me: Unexpected argument(s) '$*'" >&2;
        usage -f >&2;
        exit 1;
      fi
    ;;
  esac
  shift;
done


# ---------------------------------------------------------------------------- #

if [[ -z "${IDENT:-}" ]]; then
  if [[ -n "${NM_IS_TO:-}" ]]; then
    IDENT="${NMDIR##*node_modules/}";
  else
    IDENT="$( $JQ -r '.name // "_undeclared"' "$FROM/package.json"; )";
    if [[ "$IDENT" = '_undeclared' ]]; then
      echo "$_as_me: Cannot install module which lacks an identifier/name" >&2;
      exit 1;
    fi
  fi
fi

if [[ -n "${NM_IS_TO:-}" ]]; then
  TO="$NMDIR";
  NMDIR="${TO%/"$IDENT"}";
else
  TO="$NMDIR/$IDENT";
fi
: "${NO_PERMS=}";
: "${NO_PATCH=:}";
: "${OWNER:=$( $ID -un; )}";
: "${GROUP:=$( $ID -gn; )}";


# ---------------------------------------------------------------------------- #

# Copy package/module
$MKDIR -p "$TO";
$CHMOD 0755 "$TO";
$CP -r --no-preserve=mode,ownership --preserve=timestamp --reflink=auto -T  \
    -- "$FROM" "$TO";
if [[ -z "$NO_PERMS" ]]; then
  $CHOWN -R "$OWNER:$GROUP" "$TO";
  pushd "$FROM" >/dev/null;
  $FIND . -type f -executable -exec $CHMOD a+x "$TO/{}" \; ;
  popd >/dev/null;
fi


# ---------------------------------------------------------------------------- #

pjsHasBin() {
  $JQ -e 'has( "bin" )' "$TO/package.json" >/dev/null;
}

pjsHasBindir() {
  $JQ -e 'has( "directories" ) and ( .directories|has( "bin" ) )'  \
      "$TO/package.json" >/dev/null;
}

pjsHasBinString() {
  $JQ -e 'has( "bin" ) and ( ( .bin|type ) == "string" )'  \
      "$TO/package.json" >/dev/null;
}

pjsHasAnyBin() {
  $JQ -e 'has( "bin" ) or ( has( "directories" ) and
          ( .directories|has( "bin" ) ) )'  \
      "$TO/package.json" >/dev/null;
}


# ---------------------------------------------------------------------------- #

: "${NO_BINS=$( if pjsHasAnyBin; then echo ''; else echo ':'; fi; )}";

if [[ -z "$NO_BINS" ]]; then
  if [[ -z "${BIN_DIR:-}${BIN_PAIRS:-}" ]]; then
    if pjsHasBindir; then
      BIN_DIR="$( $JQ -r '.directories.bin' "$TO/package.json"; )";
      BIN_PAIRS="$(
        for f in "$TO/$BIN_DIR/"*; do
          [[ -d "$f" ]] && continue;
          bname="${f##*/}";
          printf '%s,%s ' "${bname%%.*}" "${f#"$TO"}";
        done
      )";
      BIN_PAIRS="${BIN_PAIRS% }";
    elif pjsHasBinString; then
      unset BIN_DIR;
      BIN_PAIRS="${IDENT#@*/},$( $JQ -r '.bin' "$TO/package.json"; )";
    else
      unset BIN_DIR;
      BIN_PAIRS="$( $JQ -r '
        .bin|to_entries|map( .key + "," + .value )|join( " " )
      ' "$TO/package.json"; )";
    fi
  fi
fi


# ---------------------------------------------------------------------------- #

if [[ -z "${NODEJS:-}$NO_PATCH" ]]; then
  NODEJS="$( $REALPATH "$( command -v node; )"; )";
fi


# ---------------------------------------------------------------------------- #

if [[ -z "$NO_BINS$NO_PERMS" ]]; then
  pushd "$TO" >/dev/null;
  if [[ -n "${BIN_DIR:-}" ]]; then
    $CHMOD -r +wx "$BIN_DIR";
  else
    $CHMOD +wx $( for bp in $BIN_PAIRS; do echo "${bp#*,}"; done; );
  fi
  popd >/dev/null;
fi


# ---------------------------------------------------------------------------- #

# TODO
#if [[ -z "$NO_BINS${NO_PATCH:-}" ]]; then
#  pushd "$TO";
#  if [[ -n "${BIN_DIR:-}" ]]; then
#    $CHMOD -r +wx "$BIN_DIR";
#  else
#    $CHMOD +wx $( for bp in $BIN_PAIRS; do echo "${bp#*,}"; done; );
#  fi
#  popd;
#fi


# ---------------------------------------------------------------------------- #

if [[ -z "$NO_BINS" ]]; then
  $MKDIR -p "$NMDIR/.bin";
  for bp in $BIN_PAIRS; do
    $LN -sr -- "$TO/${bp#*,}" "$NMDIR/.bin/${bp%,*}";
  done
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
