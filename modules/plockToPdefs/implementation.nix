# ============================================================================ #
#
# This is a naive implementation of an impure translator that does not use IFD.
# Note that in the beta repository `github:aameen-tulip/at-node-nix' these same
# processes can be done purely, and support a wider range of options concerning
# fetchers; but for the time being I am focusing on migrating the simplest
# translation flow.
#
# NOTE: This translator is designed for `package-lock.json' of
# `lockfileVersion' 2 or 3.
# The beta repository implements a version 1 translator; but that is not being
# migrated at this time.
# While I do plan to eventually migrate this - I strongly suggest that users
# upgrade their projects to use the newer lockfile schema, since it carries
# significant performance improvements for NPM usage ( `floco' routines perform
# roughly the same using either lockfile, this isn't a bottleneck for us ).
#
# ---------------------------------------------------------------------------- #

{ lib, config, basedir, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

  inherit (config) lockDir fetchers plock;


# ---------------------------------------------------------------------------- #

  # Reference [[file:../plock/types.nix][plock types]] for fields.
  toPdef = plentKey: {
    ident
  , version
  , key
  , dependencies
  , devDependencies
  , devDependenciesMeta
  , peerDependencies
  , peerDependenciesMeta
  , optionalDependencies
  , requires
  , os
  , cpu
  , engines
  , bin
  , resolved
  # NOTE: We intentionally ignore hash fields, instead we operate under the
  # assumption that translation will be run in impure mode, allowing optimized
  # SHA256 hashes to be locked instead.
  # In the beta repository `github:aameen-tulip/at-node-nix' there is an
  # implementation which uses the `builtins:fetchurl' to purely convert SHA1 or
  # SHA512 to SHA256, but that has not been migrated at this time.
  #, integrity
  #, sha1
  , link
  , hasInstallScript
  , gypfile
  , ...
  } @ plent: let
    pp    = lib.generators.toPretty {} plent;
    ltype = if plentKey == "" then "dir" else
            if link then "link" else
            if lib.hasPrefix "file" resolved then "link" else
            if lib.hasPrefix "." plentKey then "dir" else
            if lib.hasPrefix "git+" resolved then "git" else
            if lib.hasPrefix "https" resolved then "file" else
            if plentKey == resolved then "dir" else
            throw "Unable to derive lifecycle type from entry: '${pp}'.";
    # TODO: `github'
    fetchInfo = let
      type = if ltype == "file" then "tarball" else "git";
    in if builtins.elem ltype ["dir" "link"] then {
      path = let
        len = builtins.stringLength resolved;
      in if resolved == "." then lockDir else
         if lib.hasPrefix "file:" resolved
         then lockDir + ( "/" + ( builtins.substring 5 len resolved ) )
         else lockDir + ( "/" + resolved );
    } else if type == "git" then {
      inherit type;
      url        = resolved;
      allRefs    = false;
      submodules = false;
      shallow    = true;
      rev        = let
        m = builtins.match "[^#]+#([[:xdigit:]]{40})" resolved;
      in builtins.head m;
    } else { inherit type; url = resolved; };
    depInfo' = if ( ! config.includePins ) || link then {} else {
      depInfo = builtins.mapAttrs ( _: pin: { inherit pin; } )
                                  config.scopes.${plentKey}.pins;
    };
  in depInfo' // {
    inherit ident version key ltype;
    binInfo.binPairs  = bin;
    fsInfo            = { inherit gypfile; dir = "."; };
    lifecycle.install = hasInstallScript;
    fetchInfo = if fetchInfo ? path then fetchInfo else
                fetchers."fetchTree_${fetchInfo.type}".lockFetchInfo fetchInfo;
    fetcher =
      if fetchInfo ? path then "path" else "fetchTree_${fetchInfo.type}";
    metaFiles = {
      inherit lockDir plentKey;
      plent = plock.packages.${plentKey};
    } // ( if plentKey != "" then {} else { inherit plock; } );
  };


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  config._module.args.basedir = lib.mkDefault config.lockDir;


# ---------------------------------------------------------------------------- #

  options.pdefsByPath = lib.mkOption {
    type = nt.lazyAttrsOf ( nt.submodule {
      imports = [config.records.pdef];
      config._module.args = {
        inherit basedir;
        deriveTreeInfo = false;
        pdefs          = {};
      };
    } );
  };


# ---------------------------------------------------------------------------- #

  # TODO: in order to fill `treeInfo' records for anything other than the
  # root of the lockfile you need to clear any `dev' and `optional' fields,
  # and then reprocess them from the context of the "new root".
  # Additionally you need to "pull down" and `requires'.
  config.rootTreeInfo = let
    mkTreeEnt = plentKey: plent: { inherit (plent) key optional dev; };
    noDotDot  = lib.filterAttrs ( path: _: lib.hasPrefix "node_modules" path )
                                config.plents;
  in builtins.mapAttrs mkTreeEnt noDotDot;


# ---------------------------------------------------------------------------- #

  config.pdefsByPath = let
    base = builtins.mapAttrs toPdef config.plents;
    withRootTreeInfo = base // {
      "" = base."" // {
        treeInfo = config.rootTreeInfo;
      };
    };
  in if config.includeRootTreeInfo then withRootTreeInfo else base;

  config.pdefs = let
    pdl       = builtins.attrValues config.pdefsByPath;
    scrubbed  = map ( v: let
      drops = removeAttrs v ["metaFiles" "_export"];
      fixTI = if ( v.treeInfo or null ) != null then drops else
              removeAttrs drops ["treeInfo"];
    in fixTI ) pdl;
    byId      = builtins.groupBy ( v: v.ident ) scrubbed;
    byVersion = builtins.mapAttrs ( _: builtins.groupBy ( v: v.version ) ) byId;
  in builtins.mapAttrs ( _: builtins.mapAttrs ( _: vs: ( { ... }: {
    _file   = config.lockDir + "/package-lock.json";
    imports = vs;
    config._module.args = { inherit basedir; };
  } ) ) ) byVersion;


  config.exports =
    builtins.mapAttrs ( _: builtins.mapAttrs ( _: v: v._export ) ) config.pdefs;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
