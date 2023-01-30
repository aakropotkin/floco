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
    } else {
      inherit type;
      url = resolved;
    };
  in {
    inherit ident version key ltype;

    binInfo.binPairs = bin;

    metaFiles = {
      inherit lockDir plentKey;
      plent = plock.packages.${plentKey};
    } // ( if plentKey != "" then {} else { inherit plock; } );

    fsInfo = { inherit gypfile; dir = "."; };

    lifecycle.install = hasInstallScript;

    fetchInfo = if fetchInfo ? path then fetchInfo else
                fetchers."fetchTree_${fetchInfo.type}".lockFetchInfo fetchInfo;

    fetcher = if fetchInfo ? path then "path" else "fetchTree_${fetchInfo.type}";

    _module.args = { inherit basedir; };

  };


# ---------------------------------------------------------------------------- #

  #rough = let
  #  proc = plentKey: plentRaw: [
  #    {
  #      _file  = lockDir + "/package-lock.json";
  #      config = toPdef plentKey plentRaw;
  #    }
  #  ] ++ (
  #    if plentKey == "" then [{
  #      _file                   = lockDir + "/package-lock.json";
  #      config.treeInfo         = removeAttrs rootTreeInfo [""];
  #      config._export.treeInfo = let
  #        base = removeAttrs rootTreeInfo [""];
  #        nopt = builtins.mapAttrs ( _: v:
  #          if v.optional then v else removeAttrs v ["optional"]
  #        ) base;
  #        ndev = builtins.mapAttrs ( _: v:
  #          if v.dev then v else removeAttrs v ["dev"]
  #        ) nopt;
  #      in ndev;
  #    }] else []
  #  );
  #in builtins.mapAttrs proc config.plents;


# ---------------------------------------------------------------------------- #

  #configs  = builtins.concatLists ( builtins.attrValues translatedPlents );
  #packages = builtins.attrValues ( builtins.mapAttrs ( _: modules:
  #    ( lib.evalModules {
  #        modules = modules ++ [config.records.pdef];
  #      } ).config
  #  ) ( lib.filterAttrs ( path: _:
  #    ( path == "" ) || ( lib.hasPrefix "node_modules" path )
  #  ) ( translatedPlents ) ) );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  options.pdefsByPath = lib.mkOption {
    type = nt.lazyAttrsOf ( nt.submodule {
      imports = [config.records.pdef];
      config._module.args.basedir = lib.mkDefault basedir;
    } );
  };

  options.rootTreeInfo = lib.mkOption {
    type = nt.lazyAttrsOf (
      nt.submodule ../records/pdef/treeInfo/single.interface.nix
    );
    default = {};
  };


# ---------------------------------------------------------------------------- #

  config._module.args.basedir = lib.mkDefault config.lockDir;


# ---------------------------------------------------------------------------- #

  config.rootTreeInfo = let
    mkTreeEnt = plentKey: plent: { inherit (plent) key optional dev; };
    noDotDot  = lib.filterAttrs ( path: _:
      ( path == "" ) || ( lib.hasPrefix "node_modules" path )
    ) config.plents;
  in builtins.mapAttrs mkTreeEnt noDotDot;

  config.pdefsByPath = let
    base = builtins.mapAttrs toPdef config.plents;
  in base // { "" = base."" // { treeInfo = config.rootTreeInfo; }; };

  config.pdefs = let
    pdl       = builtins.attrValues config.pdefsByPath;
    scrubbed  = map ( v: removeAttrs v ["metaFiles" "_export"] ) pdl;
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
