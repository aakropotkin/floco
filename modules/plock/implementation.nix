# ============================================================================ #
#
# Typed representation of a `package-lock.json(v2/3)' file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  inherit (config) plock;

# ---------------------------------------------------------------------------- #

  plentKeyName = s: let
    m = builtins.match ".*node_modules/((@[^@/]+/)?[^@/]+)" s;
  in if m == null then null else builtins.head m;

  realEntry = k: let
    e = plock.packages.${k};
  in if e.link or false then realEntry e.resolved else e;

  linksTo = plentKey: let
    pred = k:
      ( plock.packages.${k}.link or false ) &&
      ( plock.packages.${k}.resolved == plentKey );
  in builtins.filter pred ( builtins.attrNames ( plock.packages or {} ) );


# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/plock/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.plents = lib.mkOption {
    type = nt.lazyAttrsOf ( nt.submodule {
      imports = [config.records.pjsCore.deferred ./plent/interface.nix];
    } );
    default = {};
  };

  options.scopes = lib.mkOption {
    type = nt.lazyAttrsOf ( nt.submoduleWith {
      modules = [
        ./scope/implementation.nix
        { config._module.args = { inherit (config) plents scopes; }; }
      ];
    } );
  };


# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    plock = lib.mkDefault (
      lib.importJSON ( config.lockDir + "/package-lock.json" )
    );


# ---------------------------------------------------------------------------- #

    linkedLocks = let
      hasLock = plentKey: plentRaw: let
        p = config.lockDir + ( "/" + plentRaw.resolved + "/package-lock.json" );
      in ( plentRaw.link or false ) && ( builtins.pathExists p );
      haveLock = lib.filterAttrs hasLock config.plock.packages;
      locks    = builtins.attrValues ( builtins.mapAttrs ( _: plentRaw:
        config.lockDir + ( "/" + plentRaw.resolved + "/package-lock.json" )
      ) haveLock );
    in lib.mkDefault locks;


# ---------------------------------------------------------------------------- #

    plents = let
      proc = plentKey: plentRaw: let
        # We inherit these fields "as is" from the lockfile.
        # Please note that some of these fields end up being ignored during
        # translation for the time being; but future optimizations depend on
        # these fields.
        # As routines are migrated from `github:aameen-tulip/at-node-nix' these
        # fields will be used again for various purposes.
        keeps = {
          version              = true;
          requires             = true;
          dependencies         = true;
          devDependencies      = true;
          devDependenciesMeta  = true;
          peerDependencies     = true;
          peerDependenciesMeta = true;
          optionalDependencies = true;
          #bundledDependencies  = true;
          #bundleDependencies   = true;
          dev                  = true;
          peer                 = true;
          optional             = true;
          os                   = true;
          cpu                  = true;
          resolved             = true;
          link                 = true;
          hasInstallScript     = true;
          gypfile              = true;
          bin                  = true;
          sha1                 = true;
          integrity            = true;
        };
        values = ( realEntry plentKey ) // plentRaw;
        ix     = builtins.intersectAttrs keeps values;

        ident = let
          n   = plentKeyName plentKey;
          lts = linksTo plentKey;
        in plentRaw.name or (
          if n != null then n else
          if plentKey == "" then plock.name else
          if plentRaw.link or false then ( realEntry plentKey ).name else
          if lts != [] then plentKeyName ( builtins.head lts ) else
          throw
             "Cannot derive package name from: '<PLOCK>.packages.${plentKey}'."
        );

        version = plentRaw.version or (
          if plentKey == "" then plock.version or "0.0.0-0" else
          ( realEntry plentKey ).version
        );

        bund' = let
          b = values.bundledDependencies or values.bundleDependencies or null;
        in assert     ( values ? bundledDependencies ) ->
                  ( ! ( values ? bundleDependencies  ) );
           assert     ( values ? bundleDependencies  ) ->
                  ( ! ( values ? bundledDependencies ) );
           assert builtins.elem ( builtins.typeOf b ) [
             "null" "bool" "list"
           ];
           if b == null then {} else
           if builtins.isList  then { bundledDependencies = b; } else
           if ! b then {} else {
            bundledDependencies = builtins.attrNames (
              ( values.dependencies or {} ) // ( values.requires or {} )
            );
          };

      in ix // bund' // {
        inherit ident version;

        key = ident + "/" + version;

        engines = let
          proc = eng: let
            s = builtins.match "([^ ]+) (.*)" eng;
          in { name = builtins.head s; value = builtins.elemAt s 1; };
        in if ! ( values ? engines ) then {} else
           if builtins.isAttrs values.engines then values.engines else
           builtins.listToAttrs ( map proc values.engines );

        resolved = values.resolved or (
          if plentKey == "" then "." else plentKey
        );
      };
    in builtins.mapAttrs proc ( plock.packages or {} );

# ---------------------------------------------------------------------------- #

    scopes = let
      realEntries = lib.filterAttrs ( _: v: ! ( v.link or false ) )
                                    ( plock.packages or {} );
      proc = path: { name = path; value = { inherit path; }; };
    in builtins.listToAttrs ( map proc ( builtins.attrNames realEntries ) );


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
