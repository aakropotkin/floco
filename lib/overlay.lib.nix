# ============================================================================ #
#
# Used to extend Nixpkgs' libs with `libfloco'.
#
# ---------------------------------------------------------------------------- #

final: prev: let

# ---------------------------------------------------------------------------- #

  callLibWith = { lib ? final, ... } @ auto: x: let
    f    = if prev.isFunction x then x else import x;
    args = builtins.intersectAttrs ( builtins.functionArgs f )
                                   ( { inherit lib; } // auto );
  in f args;
  callLib = callLibWith {};

  callLibsWith = auto: libs: let
    loc = "(floco#callLibsWith):";
    getLibName = x:
      if builtins.isFunction x then "<???>" else baseNameOf ( toString x );
    lnames = builtins.concatStringsSep ", " ( map getLibName libs );
    ec     = builtins.addErrorContext ( loc + " processing libs '${lnames}'" );
    proc   = acc: x: let
      l     = callLibWith auto x;
      lname = getLibName x;
      comm  = builtins.intersectAttrs acc l;
      merge = f: let
        aa  = acc.${f};
        la  = l.${f};
        msg = "${loc} ${lname}: Cannot merge conflicting definitions for " +
              "member '${f}' of types '${builtins.typeOf aa}' and " +
              "'${builtins.typeOf la}'.";
      in if builtins.isAttrs acc.${f}
         then assert builtins.isAttrs l.${f}; acc.${f} // l.${f}
         else throw msg;
      merged = builtins.foldl' ( sa: f: sa // ( merge f ) ) l
                               ( builtins.attrNames comm );
    in acc // merged;
  in ec ( builtins.foldl' proc {} libs );
  callLibs = callLibsWith {};


# ---------------------------------------------------------------------------- #

in {

  libfloco = ( callLibs [
    ./access-pdefs.nix
    ./checkSystemSupport.nix
    ./focus-tree.nix
    ./options.nix
    ./modules.nix
    ./paths.nix
    ./types.nix
  ] ) // ( import ./url-code.nix );
  libdoc = callLib ./mdoc.nix;

  inherit (final.libfloco)
    addPdefs
    getPdef

    checkSystemSupportFor

    focusTree

    mergePreferredOption
    mergeRelativePathOption
    mkKeyOption
    mkIdentOption
    mkVersionOption
    mkLtypeOption
    mkDepAttrsOption
    mkDepMetasOption

    moduleDropDefaults

    realpathRel
    isAbspath

    urlEncode
    urlDecode

    jsonAtom
    jsonValue
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
