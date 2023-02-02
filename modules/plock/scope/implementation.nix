# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, plents, scopes, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  plent = plents.${config.path};
  inherit (plent) ident;

# ---------------------------------------------------------------------------- #

  parentDir = let
    searchUp = d:
      if builtins.elem d ["." ""] then "" else
      if scopes ? d then d else searchUp ( dirOf d );
    m = builtins.match "(.*)/node_modules/${ident}" config.path;
    virtual =
      if config.path == "" then null else
      if config.path == "node_modules/${ident}" then "" else
      if config.isRoot then searchUp ( dirOf config.path ) else
      builtins.head m;
    rsl =
      if virtual == null then null else
      if plents.${virtual}.link or false then plents.${virtual}.resolved else
      virtual;
    ok = ( rsl != null ) -> ( scopes ? ${rsl} );
  in if ok then rsl else
     throw "floco: scopes: No such scope `${rsl}' for `${config.path}'.";

  pscope = if parentDir == null then null else scopes.${parentDir};


# ---------------------------------------------------------------------------- #

  allDeps = let
    reqs  = if builtins.isBool ( plent.requires or true ) then {} else
            plent.requires;
    bund = if builtins.isAttrs ( plent.bundledDependencies or {} )
           then plent.bundledDependencies or {}
           else builtins.foldl' ( acc: ident: acc // { ${ident} = true; } ) {}
                                plent.bundledDependencies;
    attrs = ( plent.dependencies or {} )         //
            ( plent.devDependencies or {} )      //
            ( plent.optionalDependencies or {} ) //
            ( plent.devDependenciesMeta or {} )  //
            reqs // bund;
  in builtins.mapAttrs ( _: _: true ) attrs;


# ---------------------------------------------------------------------------- #

in {

  _file = "<floco>/plock/scope/interface.nix";

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    isRoot = ! ( lib.hasInfix "node_modules/" config.path );

    all = config.inherited // config.direct;

    following =
      if builtins.isBool ( plent.requires or true ) then {} else
      builtins.intersectAttrs plent.requires config.inherited;

    pins = builtins.intersectAttrs allDeps config.all;


# ---------------------------------------------------------------------------- #

    inherited = if pscope == null then {} else pscope.all;

# ---------------------------------------------------------------------------- #

    direct = let
      sep  = if config.path == "" then "" else "/";
      patt = config.path + sep + "node_modules/((@[^@/]+/)?[^@/]+)";
      subs = builtins.filter ( path: ( builtins.match patt path ) != null )
                             ( builtins.attrNames plents );
      proc = acc: path: acc // {
        ${plents.${path}.ident} = plents.${path}.version;
      };
    in builtins.foldl' proc {} subs;


# ---------------------------------------------------------------------------- #

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
