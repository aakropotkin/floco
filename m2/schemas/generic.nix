# ============================================================================ #
#
# "Schemas" essentially map to `optionType' in terms of `nixpkgs' constructs,
# but retain a flat serializable declaration format for ease of re-use.
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  descriptor = {
    name        = "package descriptor";
    description = "version or URI";
    type        = {
      either = ["version" "uri"];
    };
  };


# ---------------------------------------------------------------------------- #

  version = {
    name        = "version";
    description = "semantic version number";
    type.strMatching = builtins.concatStringsSep "" [
      "(0|[1-9][[:digit:]]*)(\\.(0|[1-9][[:digit:]]*)"
      "(\\.(0|[1-9][[:digit:]]*))?)?"
      "(-((0|[1-9][[:digit:]]*)|[0-9]*[[:alpha:]-][[:alnum:]-]*)"
      "(\\.((0|[1-9][[:digit:]]*)|[0-9]*[[:alpha:]-][[:alnum:]-]*))*)?"
      "(\\+[[:alnum:]-]+(\\.[[:alnum:]]+)*)?"
    ];
  };


# ---------------------------------------------------------------------------- #

  uri = {
    name        = "URI";
    description = "uniform resource identifier";
    type        = "str";
  };


# ---------------------------------------------------------------------------- #

  ident = {
    name             = "package identifier";
    description      = "package identifier/name";
    type.strMatching = "(@[^@/]+/)?[^@/]+";
  };


# ---------------------------------------------------------------------------- #

  key = {
    name        = "package key";
    description = "unique package identifier";
    type        = "str";
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
