# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  transformDeclPaths' = {
    to ? "<floco>"
  }: option: let
    subst = p: let
      m = builtins.match ".*/floco/modules/(.*)" p;
    in if m == null then p else to + "/modules/" + ( builtins.head m );
  in option // {
    declarations = map subst option.declarations;
  };

  transformDeclPaths = transformDeclPaths' {};


# ---------------------------------------------------------------------------- #

  # Helpers taken from `<nixpkgs>/nixos/lib/make-options-doc/default.nix'

  substSpecial = x:
    if lib.isDerivation x then { _type = "derivation"; name = x.name; }
    else if builtins.isAttrs x then lib.mapAttrs (name: substSpecial) x
    else if builtins.isList x then map substSpecial x
    else if lib.isFunction x then "<function>"
    else x;


  # Produces a list of option information stripped down from the original
  # option definitions preserving only fields which are relevant for docs.
  mkOptionsList = {
    options
  , transformOptions ? transformDeclPaths
  }: let
    # This routine is what really does most of the work:
    rawOpts         = lib.optionAttrSetToDocList options;
    transformedOpts = map transformOptions rawOpts;
    filteredOpts    =
      lib.filter ( opt: opt.visible && ( ! opt.internal ) ) transformedOpts;
  in lib.flip map filteredOpts ( opt: opt
       // ( lib.optionalAttrs ( opt ? example ) {
         example = substSpecial opt.example;
       } )
       // ( lib.optionalAttrs ( opt ? default ) {
         default = substSpecial opt.default;
       } )
       // ( lib.optionalAttrs ( opt ? type) {
         type = substSpecial opt.type;
       } )
     );


  # Produces Nix expression form of doc info.
  # NOTE: in this form `{ _type = "mdDoc"; text = "..."; }' attrs still exist.
  # Those need to be processed by some `markdown' renderer.
  mkOptionsNix = {
    options
  , transformOptions ? transformDeclPaths
  } @ args: builtins.listToAttrs ( map ( o: {
    name  = o.name;
    value = removeAttrs o ["name" "visible" "internal"];
  } ) ( mkOptionsList args ) );


  # Convert Nix -> String -> Nix while stripping string context as a shortcut
  # to recursively remove all context.
  # This could be done with `lib.mapAttrsRecursive' but this is simpler.
  mkOptionsNixNoCtx = {
    options
  , transformOptions ? transformDeclPaths
  }: let
    optionsNix = mkOptionsNix { inherit options transformOptions; };
    str = builtins.unsafeDiscardStringContext ( builtins.toJSON optionsNix );
  in builtins.fromJSON str;


# ---------------------------------------------------------------------------- #

  # `delim' is a quote string such as "'" or "```".
  # Returns a list of strings where portions wrapped in quotes are nested
  # as singleton lists.
  # NOTE: this strips the original quotes.
  nonGreedySplitQuote = delim: text: let
    # NOTE: we can't use "```.*```" because of greedy matching.
    sp = builtins.split delim text;
    proc = { lst, stash } @ acc: x:
      if stash == true then acc // { stash = x; } else
      if stash != null then { lst = lst ++ [[stash]]; stash = null; } else
      if builtins.isList x then acc // { stash = true; } else
      { lst = lst ++ [x]; stash = null; };
  in if ( builtins.length sp ) <= 1 then sp else
      ( builtins.foldl' proc { lst = []; stash = null; } sp ).lst;


# ---------------------------------------------------------------------------- #

  # In this repository we only use `mdDoc' to wrap variables in "`VAR`" ticks,
  # and write code blocks with "```...```".
  # With that in mind I want to highlight that this is not a "complete"
  # `markdown' -> `org' translator by any means.
  mdToOrg = text: let
    wrapInline = t: let
      proc = acc: x:
        if builtins.isString x then acc + x else
        acc + "=" + ( builtins.head x ) + "=";
    in builtins.foldl' proc "" ( nonGreedySplitQuote "`" t );
    nestBlocks = nonGreedySplitQuote "```" text;
    winline    = map ( x:
      if builtins.isString x then wrapInline x else
      "#+BEGIN_SRC" + ( builtins.head x ) + "#+END_SRC"
    ) nestBlocks;
  in builtins.concatStringsSep "" winline;


# ---------------------------------------------------------------------------- #

  transformMdToOrg = option:
    if ( option.description._type or null ) != "mdDoc" then option else
      option // {
        description = mdToOrg option.description.text;
      };

  mkOptionsOrg = {
    options
  , transformOptions ? transformDeclPaths
  }: mkOptionsList {
    inherit options;
    transformOptions = opt: transformMdToOrg ( transformOptions opt );
  };


  renderOrgOptionHeading = {
    declarations  # list of stringized absolute paths
  , description
  , loc
  , readOnly
  , type          # uses `__toString'
  , default       ? null
  , example       ? null
  } @ fields: let
    headline = let
      depth  = builtins.length loc;
      sdepth = builtins.length ( builtins.filter ( n:
        ! ( builtins.elem n ["<name>" "*"] )
      ) loc );
      stars = let
        chars = builtins.genList ( _: "*" ) sdepth;
      in builtins.concatStringsSep "" chars;
      bname    = builtins.elemAt loc ( depth - 1 );
    in stars + " =${bname}=";
    ex = let
      e =
        if builtins.isString example then example else
        if ( example._type or null ) == "literalExpression"
        then example.text
        else lib.generators.toPretty {} example;
    in if ! ( fields ? example ) then "" else
       if ( builtins.match ".*\n.*" e ) == null
       then "- example :: =${e}=\n"
       else "- example ::\n#+BEGIN_SRC nix\n${e}\n#+END_SRC\n";
    declPaths = let
      gen = p: let
        m   = builtins.match "<floco>(/.*)" p;
        sub = if m == null then p else builtins.head m;
        url = "https://github.com/aakropotkin/floco/blob/main${sub}";
      in "[[${url}][${p}]]";
    in map gen declarations;
    t = if ( builtins.match "string matching .*" ( toString type ) ) == null
        then toString type
        else "string matching a regex pattern";
    opath = let
      base = lib.showOption loc;
    in builtins.replaceStrings ["<name>.<name>"] ["<ident>.<version>"] base;
    desc = let
      m = builtins.match "(.*[^\n])\n?" description;
    in builtins.head m;
  in ''
    ${headline}
    - option :: ~${opath}~
    - description :: ${desc}
    - type :: ${t}
    - from :: ${builtins.concatStringsSep " " declPaths}
  '' + ex;


  renderOrgFile = {
    title   ? "Floco Options Manual"
  , options
  , transformOptions ? transformDeclPaths
  }: let
    odoc  = mkOptionsOrg { inherit options transformOptions; };
    clean = map ( o:
      renderOrgOptionHeading ( removeAttrs o ["name" "visible" "internal"] )
    ) odoc;
  in builtins.concatStringsSep "\n" ( ["#+TITLE: ${title}\n"] ++ clean );


# ---------------------------------------------------------------------------- #

in {
  inherit
    mkOptionsList
    mkOptionsNix
    mkOptionsNixNoCtx
    nonGreedySplitQuote
    mdToOrg
    transformDeclPaths' transformDeclPaths
    transformMdToOrg
    mkOptionsOrg
    renderOrgOptionHeading
    renderOrgFile
  ;
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
