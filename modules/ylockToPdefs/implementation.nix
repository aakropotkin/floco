# ============================================================================ #

{ lib
, pkgs
, lockDir
, basedir ? lockDir
, ylock   ? null
, ...
} @ args: let

# ---------------------------------------------------------------------------- #

  inherit (( lib.evalModules { modules = [../fetchers]; } ).config) fetchers;


# ---------------------------------------------------------------------------- #

  ylconf = lib.evalModules {
    modules     = [../ylock];
    specialArgs = builtins.intersectAttrs {
      lib     = false;
      pkgs    = false;
      lockDir = false;
      basedir = true;
      ylock   = true;
    } args;
  };

  inherit (ylconf.config) ylock ylents;


# ---------------------------------------------------------------------------- #

  toPdef = ylentKey: {
    ident
  , version
  , key
  , dependencies
  , devDependencies
  , devDependenciesMeta
  , peerDependencies
  , peerDependenciesMeta
  , optionalDependencies
  , bin
  , checksum
  , descriptors
  , linkType
  , resolution
  , languageName
  , ...
  } @ ylent: let
    pp    = lib.generators.toPretty {} ylent;
    unpatched = let
      m = builtins.match ".*@patch:([^#]+)#.*" resolution;
    in if m == null then null else
       lib.urlDecode ( builtins.head m );
    ltype =
      if "${ident}@workspace:." == resolution then "dir" else
      if linkType == "soft" then "link" else
      if lib.hasPrefix "${ident}@workspace:" resolution then "link" else
      if lib.hasPrefix "${ident}@npm:" resolution then "file" else
      if lib.hasInfix "\.git#" resolution then "git" else
      if ( unpatched != null ) && ( lib.hasPrefix "npm:" unpatched )
      then "file"
      else throw "Unable to derive lifecycle type from entry: '${pp}'.";
    fetchInfo = let
      type = if ltype == "file" then "tarball" else "git";
      len  = builtins.stringLength resolution;
      # For revs: "<IDENT>@https://github.com/<USER>/<REPO>.git#commit=<FULL-REV>"
      rev   = let
        m = builtins.match "[^#]+#commit=([[:xdigit:]]{40})" resolution;
      in if m == null then null else builtins.head m;
      ref   = let
        m = builtins.match "[^#]+#(.*)" resolution;
      in if m == null then "HEAD" else builtins.head m;
      revOrRef' = if rev == null then { inherit ref; } else { inherit rev; };
    in if builtins.elem ltype ["dir" "link"] then {
      path = let
        rplen = builtins.stringLength "${ident}@workspace:";
      in if resolution == "${ident}@workspace:." then lockDir else
         lockDir + ( "/" + ( builtins.substring rplen len resolution ) );
    } else if type == "git" then {
      inherit type;
      url = let
        rglen = ( builtins.stringLength ident ) + 1;
      in builtins.substring rglen len resolution;
      allRefs    = rev != null;
      submodules = false;
      shallow    = true;
    } // revOrRef' else {
      inherit type;
      url = "https://registry.npmjs.org/${ident}/-/" +
            "${baseNameOf ident}-${version}.tgz";
    };
  in {
    inherit ident version key ltype fetchInfo;
    binInfo.binPairs = bin;  /* TODO: I'm not sure if this might be directory */
    metaFiles = {
      inherit lockDir ylentKey ylent;
    };
    fetcher =
      if fetchInfo ? path then "path" else "fetchTree_${fetchInfo.type}";
    _module.args = { inherit basedir; };
  };


# ---------------------------------------------------------------------------- #

in {

  exports = let
    proc = ylentKey: ylent: let
      mod = {
        _file  = lockDir + "/yarn.lock";
        config = toPdef ylentKey ylent;
      };
    in ( lib.evalModules { modules = [mod ../pdef]; } ).config._export;
  in builtins.attrValues ( builtins.mapAttrs proc ylents );

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
