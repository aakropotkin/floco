# ============================================================================ #
#
# Typed representation of a `package-lock.json(v2/3)' file.
#
# ---------------------------------------------------------------------------- #

{ lib
, lockDir
, plock   ? lib.importJSON "${lockDir}/package-lock.json"
, ...
}: let

  nt = lib.types;

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

  config = {
    inherit plock lockDir;
    inherit (plock) lockfileVersion;
    plents = let
      proc = plentKey: plentRaw: let
        keeps = {
          version              = true;
          requires             = true;
          dependencies         = true;
          devDependencies      = true;
          devDependenciesMeta  = true;
          peerDependencies     = true;
          peerDependenciesMeta = true;
          optionalDependencies = true;
          dev                  = true;
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
          if plentKey == "" then plock.version else
          ( realEntry plentKey ).version
        );
      in ix // {
        inherit ident version;

        key     = ident + "/" + version;

        engines = let
          proc = acc: eng: let
            s = builtins.match "([^ ]+) (.*)" eng;
          in acc // { ${builtins.head s} = builtins.elemAt s 1; };
        in if ! ( values ? engines ) then {} else
           if builtins.isAttrs values.engines then values.engines else
           builtins.foldl' proc {} values.engines;

        resolved = values.resolved or (
          if plentKey == "" then "." else plentKey
        );
      };
    in builtins.mapAttrs proc ( plock.packages or {} );
  };

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
