# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  jsonAtom = nt.nullOr ( nt.oneOf [nt.str nt.bool nt.int nt.float] );

  jsonValue = ( nt.oneOf [
    lib.libfloco.jsonAtom
    ( nt.listOf jsonValue )
    ( nt.attrsOf jsonValue )
  ] ) // {
    description = "A JSON compliant value";
  };


# ---------------------------------------------------------------------------- #

  version = let
    da_c      = "[[:alpha:]-]";
    dan_c     = "[[:alnum:]-]";
    num_p     = "(0|[1-9][[:digit:]]*)";
    part_p    = "(${num_p}|[0-9]*${da_c}${dan_c}*)";
    core_p    = "${num_p}(\\.${num_p}(\\.${num_p})?)?";
    tag_p     = "${part_p}(\\.${part_p})*";
    build_p   = "${dan_c}+(\\.[[:alnum:]]+)*";
    version_p = "${core_p}(-${tag_p})?(\\+${build_p})?";
  in nt.strMatching version_p;


# ---------------------------------------------------------------------------- #

  uri = nt.str;


# ---------------------------------------------------------------------------- #

  descriptor = nt.either lib.libfloco.version lib.libfloco.uri;


# ---------------------------------------------------------------------------- #

  ident = nt.strMatching "(@[^@/]+/)?[^@/]+";


# ---------------------------------------------------------------------------- #

  key = nt.str;


# ---------------------------------------------------------------------------- #

  ltype = ( nt.enum ["file" "link" "dir" "git"] ) // {
    merge = lib.libfloco.mergePreferredOption {
      compare = a: b:
        if a == "file" then true else if b == "file" then false else
        if a == "dir"  then true else if b == "dir"  then false else
        if a == "link" then true else if b == "link" then false else
        true;
    };
  };


# ---------------------------------------------------------------------------- #

  # `package.json', `package-lock.json', and other non-`floco' metadata.
  depAttrs = nt.attrsOf lib.libfloco.descriptor;
  depMetas = nt.attrsOf ( nt.attrsOf nt.bool );


# ---------------------------------------------------------------------------- #

  binPairs = nt.attrsOf nt.str;
  pjsBin   = nt.either nt.str lib.libfloco.binPairs;


# ---------------------------------------------------------------------------- #

  uniqueListOf = elemType: ( nt.listOf elemType ) // {
    description = "A list of unique ${elemType.description}";
    merge       = loc: defs: lib.unique ( lib.getValues defs );
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    jsonAtom
    jsonValue

    version
    uri
    descriptor
    ident
    key
    ltype

    depAttrs
    depMetas

    binPairs
    pjsBin

    uniqueListOf
  ;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
