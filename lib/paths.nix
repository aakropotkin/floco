# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  # Count the number of matches in a string.
  countMatches = splitter: string:
    builtins.length (
      builtins.filter builtins.isList ( builtins.split splitter string )
    );


# ---------------------------------------------------------------------------- #

  strp = v:
    ( builtins.isString v ) ||
    ( ( v ? __toString ) && ( builtins.isFunction v.__toString ) );


# ---------------------------------------------------------------------------- #

  # Can `x' be coerced to a Path?
  isCoercibleToPath = x: ( strp x ) || ( builtins.isPath x ) || ( x ? outPath );


  # Force a path-like `x' to be a path.
  # Store paths will be returned as strings, non-store paths will be returned
  # as a `path' value.
  coercePath = x: let
    p      = x.outPath or ( toString x );
    asPath = if lib.hasPrefix "/nix/store" p then p else /. + p;
  in if builtins.isPath x then x else asPath;


# ---------------------------------------------------------------------------- #

  # Is path-like `x' an absolute path?
  # This is always true for Path types, but we're really interested in checking
  # for whether or not a relative path-like (string) needs to be resolved.
  isAbspath = x:
    if builtins.isPath x then true else
    if ! ( strp x ) then
      throw "Cannot get absolute path of type: ${builtins.typeOf x}"
    else ( x != "" ) && ( ( builtins.substring 0 1 x ) == "/" );

  # Resolve a relative path to an absolute pathstring.
  # Uses `basedir' to resolve relative paths.
  asAbspath' = basedir: path:
    if isAbspath path then toString path else
    if builtins.isPath basedir then basedir + ( "/" + path ) else
    /. + ( basedir + "/" + path );

  asAbspath = x:
    if ( builtins.isString x ) || ( builtins.isPath x ) then asAbspath' x else
    if ( x ? basedir ) && ( x ? path ) then asAbspath' x.basedir x.path else
    if ( x ? basedir ) && ( x ? relpath ) then asAbspath' x.basedir x.relpath
    else asAbspath' ( x.basedir or ( toString x ) );


# ---------------------------------------------------------------------------- #

  takeUntil = cond: lst: let
    proc = { rsl, done } @ acc: x:
      if acc.done then acc else
      if cond x   then acc // { done = true; } else
      acc // { rsl = rsl ++ [x]; };
  in ( builtins.foldl' proc { done = false; rsl = []; } lst ).rsl;


# ---------------------------------------------------------------------------- #

  commonPrefix = a: b: let
    alen    = builtins.length a;
    blen    = builtins.length b;
    maxLen  = if alen < blen then alen else blen;
    a'      = lib.take maxLen a;
    b'      = lib.take maxLen b;
    idxList = builtins.genList ( x: x ) maxLen;
    proc    = i: ( builtins.elemAt a' i ) != ( builtins.elemAt b' i );
    commons = takeUntil proc idxList;
  in lib.take ( builtins.length commons ) a';


# ---------------------------------------------------------------------------- #

  # Return the nearest common parent directory for path-likes `a' and `b'.
  # This will eventually fall back to "/" if needed.
  # Common parent is detected by path splitting alone - symlinks or files on
  # different filesystems will be treated naively.
  commonParent = a: b: let
    splitSlash = s: builtins.filter builtins.isString ( builtins.split "/" s );
    a' = splitSlash a;
    b' = splitSlash b;
    common = commonPrefix a' b';
  in if ( common == [] ) then "/" else ( builtins.concatStringsSep "/" common );


# ---------------------------------------------------------------------------- #

  # Get relative path between parent and subdir.
  # This will not work for non-subdirs.
  realpathRel' = from: to: let
    inherit (builtins) substring stringLength length split concatStringsSep;
    p = toString ( /. + from );
    s = asAbspath from to;
    dropP = "." + ( substring ( stringLength p ) ( stringLength s ) s );
    isSub = ( stringLength p ) < ( stringLength s );
    swapped = realpathRel' s p;
    dist = countMatches "/" swapped;
    dots = concatStringsSep "/" ( builtins.genList ( _: ".." ) dist );
  in if ( p == s ) then "." else if isSub then dropP else dots;


  # This handles non-subdirs.
  # WARNING:
  # This function has no idea if your arguments are dirs or files!
  # It will assume that they are directories.
  # Also be mindful of how Nix may expand a Path ( type ) vs. a string.
  realpathRel = _from: _to: let
    from         = toString _from;
    to           = toString _to;
    parent       = commonParent from to;
    fromToParent = realpathRel' from parent;
    parentToTo   = realpathRel' parent to;
    joined       = "${fromToParent}/${parentToTo}";
    san = builtins.replaceStrings ["/./"] ["/"] joined;
    sanF = s: let m = builtins.match "(\\./)(.*)" s; in
              if ( m == null ) then s else ( builtins.elemAt m 1 );
    sanE = s: let m = builtins.match "(.*)(/\\.)" s; in
              if ( m == null ) then s else ( builtins.head m );
  in sanE ( sanF san );


# ---------------------------------------------------------------------------- #

in {

  inherit
    isAbspath
    realpathRel
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
