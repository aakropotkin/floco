#! /usr/bin/env bash
# ============================================================================ #
#
# Install a prepared module to a `node_modules/' path without
# handling dependencies.
#
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

  IDENT       Treat \`IDENT' as the package identifier/name.
  NO_BINS     Skip processing of bins if non-empty. 
  BIN_PAIRS   Space separated tuples of executables to be installed as:
              \`BIN-NAME,REL-PATH BIN-NAME2,REL-PATH...\'
  BIN_DIR     Relative path to directory containing scripts to be installed as
              executables ( drops any extension for exposed bin ).
              This variable is ignored if \`BIN_PAIRS' is non-empty.
  NO_PERMS    Skip checking/fixup of directory and executable permissions
              when non-empty.
  NO_PATCH    Skip patching shebangs in scripts when non-empty.
  NODEJS      Absolute path to \`node' executable.
              May be omitted if patching shebangs is disabled.
  JQ          Absolute path to \`jq' executable. ( Optional )
              May be omitted if \`IDENT' is known and any \`*BIN*' variable is
              is non-empty ( it is only needed to read \`package.json' ).
  CHMOD       Absolute path to \`chmod' executable. ( Optional )
  MKDIR       Absolute path to \`mkdir' executable. ( Optional )
  CP          Absolute path to \`cp' executable.    ( Optional )
              This is useful for adding additional flags or wrapping the
              program used to copy files.
  REALPATH    Absolute path to \`realpath' executable. ( Optional )
";


# ---------------------------------------------------------------------------- #

usage() {
  echo "$_usage_msg";
  [[ "${1:-}" = "-f" ]] && echo "$_help_msg";
}



# ---------------------------------------------------------------------------- #

: "${JQ:=jq}";
: "${CHMOD:=chmod}";
: "${MKDIR:=mkdir}";
: "${CP:=cp}";
: "${REALPATH:=realpath}";

unset FROM NMDIR TO;

while [[ "$#" -gt 0 ]]; do
  case "$1" in
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
        FROM="$1";
      elif [[ -z "${NMDIR:-}" ]]; then
        NMDIR="$1";
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

if [[ -z "${NODEJS:-}${NO_PATCH:-}" ]]; then
  NODEJS="$( $REALPATH "$( command -v node; )"; )";
fi

# TODO


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
