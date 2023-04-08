# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  jsonAtom = ( nt.nullOr ( nt.oneOf [nt.str nt.bool nt.int nt.float] ) ) // {
    name        = "JSON atom";
    description = "JSON `null`, `string`, `bool`, or `number` value";
  };

  jsonValue = ( nt.oneOf [
    jsonAtom
    ( nt.listOf jsonValue )
    ( nt.attrsOf jsonValue )
  ] ) // {
    name        = "JSON value";
    description = "JSON compliant value";
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
  in ( nt.strMatching version_p ) // {
    name        = "version";
    description = "semantic version number";
  };


# ---------------------------------------------------------------------------- #

  uri = nt.str // {
    name        = "URI";
    description = "uniform resource identifier";
  };


# ---------------------------------------------------------------------------- #

  descriptor = ( nt.either version uri ) // {
    name        = "package descriptor";
    description = "version or URI";
  };


# ---------------------------------------------------------------------------- #

  ident = ( nt.strMatching "(@[^@/]+/)?[^@/]+" ) // {
    name        = "package identifier";
    description = "package identifier/name";
  };


# ---------------------------------------------------------------------------- #

  key = nt.str // {
    name        = "package key";
    description = "unique package identifier";
  };


# ---------------------------------------------------------------------------- #

  ltype = ( nt.enum ["file" "link" "dir" "git"] ) // {
    name        = "lifecycle type";
    description = "lifecycle type as recognized by `npm`";
    merge       = lib.libfloco.mergePreferredOption {
      compare = a: b:
        if a == "file" then true else if b == "file" then false else
        if a == "dir"  then true else if b == "dir"  then false else
        if a == "link" then true else if b == "link" then false else
        true;
    };
  };


# ---------------------------------------------------------------------------- #

  # `package.json', `package-lock.json', and other non-`floco' metadata.
  depAttrs = nt.attrsOf descriptor;
  depMetas = nt.attrsOf ( nt.attrsOf nt.bool );


# ---------------------------------------------------------------------------- #

  relpath = ( nt.strMatching "[^/[:space:]].*" ) // {
    name        = "relative path";
    description = "relative path without leading slash";
  };

  storePath = ( nt.strMatching ( builtins.storeDir + "/.*" ) ) // {
    name        = "nix store path";
    description = "path to a file/directory in the nix store";
  };


# ---------------------------------------------------------------------------- #

  binPairs = nt.attrsOf nt.str;
  pjsBin   = nt.either nt.str binPairs;


# ---------------------------------------------------------------------------- #

  sha256_hash = ( nt.strMatching "[[:xdigit:]]{64}" ) // {
    name        = "SHA-256 hex";
    description = "SHA-256 hash (hexadecimal)";
  };
  sha256_sri = ( nt.strMatching "sha256-[a-zA-Z0-9+/]{42,44}={0,2}" ) // {
    name        = "SHA-256 SRI";
    description = "SHA-256 hash (SRI)";
  };
  narHash = sha256_sri // {
    name        = "narHash";
    description = "NAR hash (SHA256 SRI)";
  };


# ---------------------------------------------------------------------------- #

  rev = ( nt.strMatching "[[:xdigit:]]{40}" ) // {
    name        = "rev";
    description = "SHA-1 revision (hexadecimal)";
  };
  short_rev = ( nt.strMatching "[[:xdigit:]]{7}" ) // {
    name        = "short rev";
    description = "first 7 characters of SHA-1 revision (hexadecimal)";
  };


# ---------------------------------------------------------------------------- #

  depPin = let
    base = nt.nullOr version;
  in base // {
    name        = "pin";
    description = "pinned version";
    merge       = loc: defs: let
      values = lib.getValues defs;
      nnull  = builtins.filter ( x: x != null ) values;
      cmp    = a: b: ( builtins.compareVersions a b ) < 0;
    in if ( builtins.length values ) == 1 then builtins.head values else
       if ( builtins.length nnull ) == 0 then null else
       if ( builtins.length nnull ) == 1 then builtins.head nnull else
       builtins.head ( builtins.sort cmp nnull );
  };


# ---------------------------------------------------------------------------- #

  boolAny = nt.bool // {
    merge = loc: defs: builtins.any ( x: x ) ( lib.getValues defs );
  };

  boolAll = nt.bool // {
    merge = loc: defs: builtins.all ( x: x ) ( lib.getValues defs );
  };


# ---------------------------------------------------------------------------- #

  uniqueListOf = elemType: let
    base = nt.listOf elemType;
  in base // {
    name        = "unique list of ${elemType.name}";
    description = "unique list of (${elemType.description})";
    merge       = loc: defs: lib.unique (
      builtins.concatLists ( lib.getValues defs )
    );
  };


# ---------------------------------------------------------------------------- #

  ivkey = nt.submodule ( { config, ... }: {
    options = {
      key     = lib.libfloco.mkKeyOption;
      ident   = lib.libfloco.mkIdentOption;
      version = lib.libfloco.mkVersionOption;
    };
    config = {
      key     = lib.mkDefault ( config.ident + "/" + config.version );
      ident   = lib.mkDefault ( dirOf config.key );
      version = lib.mkDefault ( baseNameOf config.key );
    };
  } );

  mkIVKeyOption = lib.mkOption {
    description = lib.mdDoc ''
      Record of `ident` ( name ), `version` ( semver ), and
      `key` ( `<IDENT>/<VERSION>` ) fields used to identify modules.
    '';
    type = ivkey;
  };


# ---------------------------------------------------------------------------- #

  keylike = let
    fromT = nt.either
      key
      ( nt.addCheck ( nt.attrsOf nt.raw )
                    ( x: ( ( x ? ident ) || ( x ? name ) ) &&
                         ( ( x ? version ) || ( x ? pin ) ) ) );
    coerce = x: let
      key   = if builtins.isString x then x else ident + "/" + version;
      ident = if builtins.isString x then dirOf x else
              x.ident or x.name or ( dirOf key );
      version = if builtins.isString x then baseNameOf x else
                x.version or x.pin or ( baseNameOf key );
    in { inherit key ident version; };
  in nt.coercedTo fromT coerce ivkey;

  mkKeylikeOption = lib.mkOption {
    description = lib.mdDoc ''
      A string or attrset that is coercible to a `key`.
      This may be a plain string ( `key` ), or an attrset with at least a `key`
      field, or an `ident`/`name` field and `version`/`pin` fields.

      This type implicitly converts assignments to an attrset of
      `{ key, ident, version }`.
    '';
    type = keylike;
  };


  runKeylike = x: let
    key = if builtins.isString x then x else
          x.key or ( ident + "/" + version );
    ident   = x.ident or x.name or ( dirOf key );
    version = x.version or x.pin or ( baseNameOf key );
  in { inherit key ident version; };


# ---------------------------------------------------------------------------- #

  runType = type: x:
    ( lib.evalOptionValue [] ( lib.mkOption { inherit type; } ) [{
        file  = "<libfloco>/types.nix:runType(${type.name})";
        value = x.config or x;
      }] ).value;

  #runType = type: x: let
  #  toDef = e: {
  #    file  = e.file or "<libfloco>/types.nix:runType(${type.name})";
  #    value = e.value or e;
  #  };
  #  isListOfDefs = let
  #    fst = builtins.head x;
  #  in /* ( type.name == "listOf" ) && */ ( x != [] ) && (
  #    ( builtins.isAttrs fst ) && ( fst ? value )
  #  );
  #  defs =
  #    if type.name != "listOf" then map toDef ( lib.toList x ) else
  #    if isListOfDefs then map toDef x else
  #    [( toDef x )];
  #in ( lib.mergeDefinitions [] type defs ).mergedValue;


# ---------------------------------------------------------------------------- #

  # This is best defined as an attrset to avoid fucky merge operations that try
  # to coerce submodules from functions.
  functorTo = elemType: let
    base = nt.lazyAttrsOf nt.raw;
    pred = x:
      ( x ? __functor ) &&
      ( builtins.isFunction x.__functor ) &&
      ( builtins.isFunction ( x.__functor x ) );
  in ( nt.addCheck base pred ) // {
    name        = "functorTo(${elemType.name})";
    description = "functor that evaluates to a(n) ${elemType.description}";
  };

  # `functorTo' must be checked first, otherwise it will be misidentified as
  # a function and wrapped in a way that makes introspection impossible.
  funkTo = elemType:
    nt.either ( functorTo elemType ) ( nt.functionTo elemType );


# ---------------------------------------------------------------------------- #

  emptyStr = ( nt.enum [""] ) // {
    name        = "emptyStr";
    description = "empty string";
  };


# ---------------------------------------------------------------------------- #

  treePath = let
    treeRelPath = ( nt.strMatching "[^./][^./]?.*" ) // {
      name        = "treePath";
      description = "node_modules tree path";
    };
  in nt.either emptyStr treeRelPath;


  mkTreePathOption = lib.mkOption {
    description = lib.mdDoc ''
      A `node_modules/*` tree path.
      Either the empty string, or a relative path with no leading "./" part.
    '';
    type    = treePath;
    default = "";
  };


# ---------------------------------------------------------------------------- #

in {

  inherit
    boolAny boolAll

    jsonAtom jsonValue

    uri

    version descriptor
    ident key
    ltype
    depAttrs depMetas
    binPairs pjsBin

    relpath storePath

    sha256_hash sha256_sri narHash
    rev short_rev
    depPin

    uniqueListOf

    ivkey   mkIVKeyOption
    keylike mkKeylikeOption
    runKeylike

    runType

    functorTo funkTo

    emptyStr
    treePath mkTreePathOption

  ;

} // ( import ./types/graph.nix { inherit lib; } )
  // ( import ./types/topo.nix  { inherit lib; } )
  // ( import ./types/pjsCore   { inherit lib; } )
  // ( import ./types/depInfo   { inherit lib; } )
  // ( import ./types/pdef.nix  { inherit lib; } )


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
