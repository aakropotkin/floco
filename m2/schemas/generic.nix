# ============================================================================ #
#
# "Schemas" essentially map to `optionType' in terms of `nixpkgs' constructs,
# but retain a flat serializable declaration format for ease of re-use.
#
# Siblings `{types,options}/generic.nix' create types and options from these
# schemas for use with `nix', but in this flat form they're also trivial to
# use elsewhere to recycle descriptions or generate documentation.
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  version = {
    name             = "version";
    description      = "semantic version number";
    type.strMatching = let
      num_p  = "(0|[1-9][[:digit:]]*)";
      core_p = "${num_p}(\\.${num_p}(\\.${num_p})?)?";
      part_p = "(${num_p}|[0-9]*[[:alpha:]-][[:alnum:]-]*)";
      tag_p  = "${part_p}(\\.${part_p})*";
    in "${core_p}(-${tag_p})?(\\+[[:alnum:]-]+(\\.[[:alnum:]]+)*)?";
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
