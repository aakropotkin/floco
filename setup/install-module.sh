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

_version='0.1.0';

_usage_msg="Usage: install-module.sh [OPTIONS] FROM NM-DIR

Module rooted at \`FROM' ( as \`FROM/package.json' ), will be installed to
\`NM-DIR/<NAME>' symlinking any executables to \`NM-DIR/.bin'.
";

_help_msg="$_usage_msg
Options:
  -t,--to             Treat \`NM-DIR' as literal install dir
  -i,--ident ID       Treat \`ID' as the package identifier/name
  -b,--bins           Force processing of bins
  -B,--no-bins        Skip processing bins
  -p,--perms          Force fixing of \`FROM' permissions for dirs and bins
  -P,--no-perms       Skip checking of \`FROM' permissions, copy them \"as is\"
  -s,--patch          Force patching shebangs
  -S,--no-patch       Skip patching shebangs
  -l,--bin-links      Force creation of executable symlinks
  -L,--no-bin-links   Skip creation of executable symlinks
  -u,--usage          Print usage message to STDOUT
  -h,--help           Print this message to STDOUT
  -V,--version        Print version to STDOUT

Environment:
  The following environment variables may be used unless explicitly overridden
  by options/flags mentioned above.
  These variables are not required, but may be used as an optimization to skip
  reading the contents of \`package.json'.

  Variables marked as \"Bool\" are treated as false when unset or set to the
  empty string, or true for any non-empty value.
  Flags will always take priority over environment variables.

  IDENT         Treat \`IDENT' as the package identifier/name.
  NO_BINS       Skip processing of bins if non-empty. ( Bool )
  BIN_PAIRS     Space separated tuples of executables to be installed as:
                \`BIN-NAME,REL-PATH BIN-NAME2,REL-PATH...'
  BIN_DIR       Relative path to directory containing scripts to be installed as
                executables ( drops any extension for exposed bin ).
                This variable is ignored if \`BIN_PAIRS' is non-empty.
  NO_BIN_LINKS  Skip creation of executable symlinks. ( Bool )
  NO_PERMS      Skip checking/fixup of directory and executable permissions
                when non-empty. ( Bool )
  NO_PATCH      Skip patching shebangs in scripts when non-empty. ( Bool )
  NODEJS        Absolute path to \`node' executable.
                May be omitted if patching shebangs is disabled.
  JQ            Absolute path to \`jq' executable.
                May be omitted if \`IDENT' is known and any \`*BIN*' variable is
                is non-empty ( it is only needed to read \`package.json' ).
  ID            Absolute path to \`id' executable.
  CHMOD         Absolute path to \`chmod' executable.
  CHOWN         Absolute path to \`chown' executable.
  MKDIR         Absolute path to \`mkdir' executable.
  CP            Absolute path to \`cp' executable.
                This is useful for adding additional flags or wrapping the
                program used to copy files.
  LN            Absolute path to \`ln' executable.
  REALPATH      Absolute path to \`realpath' executable.
  TAIL          Absolute path to \`tail' executable.
  FIND          Absolute path to \`find' executable.
  BASH          Absolute path to \`bash' executable.
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
: "${JQ:=jq}";
: "${CHMOD:=chmod}";
: "${CHOWN:=chown}";
: "${MKDIR:=mkdir}";
: "${TAIL:=tail}";
: "${CP:=cp}";
: "${REALPATH:=realpath}";
: "${FIND:=find}";
: "${LN:=ln}";
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
    -t|--to)           NM_IS_TO=:; ;;
    -i|--ident)        IDENT="$2"; shift; ;;
    -b|--bins)         NO_BINS=''; ;;
    -B|--no-bins)      NO_BINS=:; unset BIN_PAIRS BIN_DIR; ;;
    -p|--perms)        NO_PERMS=''; ;;
    -P|--no-perms)     NO_PERMS=:; ;;
    -s|--patch)        NO_PATCH=''; ;;
    -S|--no-patch)     NO_PATCH=:; unset NODEJS; ;;
    -l|--bin-links)    NO_BIN_LINKS=; ;;
    -L|--no-bin-links) NO_BIN_LINKS=:; ;;
    -u|--usage)        usage;    exit 0; ;;
    -h|--help)         usage -f; exit 0; ;;
    -v|--version)      echo "$_version"; exit 0; ;;
    -?|--*)
      echo "$_as_me: Unrecognized option: '$1'" >&2;
      usage -f >&2;
      exit 1;
    ;;
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
: "${NO_BIN_LINKS=}";
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

# Identical to `<nixpkgs>/pkgs/stdenv/generic/setup.sh'
pjsIsScript() {
  local fn="$1";
  local fd;
  local magic;
  exec {fd}< "$fn";
  read -r -n 2 -u "$fd" magic;
  exec {fd}<&-
  if [[ "$magic" =~ \#! ]]; then
    return 0;
  else
    return 1;
  fi
}


pjsPatchNodeShebang() {
  local timestamp oldInterpreterLine oldPath arg0 args;
  pjsIsScript "$1"||return 0;
  read -r oldInterpreterLine < "$1";
  read -r oldPath arg0 args <<< "${oldInterpreterLine:2}";
  # Only modify `node' shebangs.
  case "$oldPath $arg0" in
    */bin/env\ *node) :; ;;
    */node\ |node\ )
      case "$oldPath" in
        $NIX_STORE/*) return 0; ;;
        *) :; ;;
      esac
      :;
    ;;
    *) return 0; ;;
  esac
  timestamp="$( stat --printf '%y' "$1"; )";
  if [[ -z "${NODEJS:-}" ]]; then
    NODEJS="$(
      $REALPATH "$( PATH="${HOST_PATH:-$PATH}"; command -v node; )";
    )";
  fi
  printf '%s'                                                         \
    "$1: interpreter directive changed from \"$oldInterpreterLine\""  \
    " to \"#!${NODEJS:?}\"" >&2;
  echo '' >&2;
  {
    echo "#!$NODEJS";
    $TAIL -n +2 "$1";
  } > "$1~";
  $CHMOD 0755 "$1~";
  mv -- "$1~" "$1";
  touch --date "$timestamp" "$1";
}

if [[ -z "$NO_BINS${NO_PATCH:-}" ]]; then
  pushd "$TO";
  for bp in $BIN_PAIRS; do
    _bin="${bp#*,}";
    _bin="${_bin#/}";
    _bin="./${_bin#./}";
    pjsPatchNodeShebang "$_bin";
  done
  popd;
elif [[ -z "$NO_BINS$NO_PERMS" ]]; then
  pushd "$TO" >/dev/null;
  # shellcheck disable=SC2046
  $CHMOD +wx $( for bp in $BIN_PAIRS; do
    _bin="${bp#*,}";
    _bin="${_bin#/}";
    _bin="./${_bin#./}";
    echo "$_bin";
  done; );
  popd >/dev/null;
fi


# ---------------------------------------------------------------------------- #

# So a handful of dingbats out there wrote `"bin": { "foo": "/bin/foo" }', so
# we have to be careful to strip prefixes.
# I haven't checked to see exactly how NPM responds to these, but I imagine they
# do the exact same thing.

if [[ -z "$NO_BINS$NO_BIN_LINKS" ]]; then
  $MKDIR -p "$NMDIR/.bin";
  for bp in $BIN_PAIRS; do
    if [[ -L "$NMDIR/.bin/${bp%,*}" ]]; then
      echo "$_as_me: WARNING: creation of '$NMDIR/.bin/${bp%,*}' skipped - \
file already exists." >&2;
    else
      _bin="${bp#*,}";
      _bin="${_bin#/}";
      _bin="${_bin#./}";
      $LN -sr -- "$TO/$_bin" "$NMDIR/.bin/${bp%,*}";
    fi
  done
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
