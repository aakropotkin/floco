# ============================================================================ #
#
# "Schemas" essentially map to `optionType' in terms of `nixpkgs' constructs,
# but retain a flat serializable declaration format for ease of re-use.
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  version = {
    name             = "version";
    description      = "semantic version number";
    type.strMatching = builtins.concatStringsSep "" [
      "(0|[1-9][[:digit:]]*)(\\.(0|[1-9][[:digit:]]*)"
      "(\\.(0|[1-9][[:digit:]]*))?)?"
      "(-((0|[1-9][[:digit:]]*)|[0-9]*[[:alpha:]-][[:alnum:]-]*)"
      "(\\.((0|[1-9][[:digit:]]*)|[0-9]*[[:alpha:]-][[:alnum:]-]*))*)?"
      "(\\+[[:alnum:]-]+(\\.[[:alnum:]]+)*)?"
    ];
    example = "4.2.0-pre";
  };


# ---------------------------------------------------------------------------- #

  uri = {
    name        = "URI";
    description = "uniform resource identifier";
    type        = "str";
    example     = "https://registry.npmjs.org/lodash";
  };


# ---------------------------------------------------------------------------- #

  descriptor = {
    name        = "package descriptor";
    description = "version or URI";
    type.either = ["version" "uri"];
    example     = "^4.2.0";
  };


# ---------------------------------------------------------------------------- #

  ident = {
    name             = "package identifier";
    description      = "package identifier/name";
    type.strMatching = "(@[^@/]+/)?[^@/]+";
    example          = "@floco/phony";
  };


# ---------------------------------------------------------------------------- #

  key = {
    name        = "package key";
    description = "unique package identifier";
    type        = "str";
    example     = "@floco/phony/4.2.0";
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
