let
  lib.importJSON = f: builtins.fromJSON ( builtins.readFile f );
  lib.test       = p: s: ( builtins.match p s ) != null;
  lib.yank       = p: s: builtins.head ( builtins.match p s );
  lib.yankN      = n: p: s: builtins.elemAt ( builtins.match p s ) n;
  lib.stripPath  = p:
    if builtins.isPath p then p else lib.yankN 1 "(\\./)?(.*[^/])/?" p;
  lib.joinPaths2 = a: b:
    if builtins.elem b ["." "./." "" null] then a else
    ( lib.stripPath a ) + "/" + ( lib.stripPath b );
in {
  ident     ? dirOf fields.key
, version   ? baseNameOf fields.key
, key       ? ident + "/" + version
, ltype     ? "file"
, depInfo   ? {}
, binInfo   ? { binPairs = {}; }
, fetchInfo ? {
    type = "tarball";
    url  = "https://registry.npmjs.org/${ident}/-/" +
           "${baseNameOf ident}-${version}.tgz";
  }
, sourceInfo ? builtins.fetchTree fetchInfo
, fsInfo     ? {
    gypfile = builtins.pathExists (
      lib.joinPaths2 sourceInfo.outPath "${fsInfo.dir}/binding.gyp"
    );
    dir = ".";
  }
, lifecycle ? { install = true; build = ltype != "file"; }
, sysInfo   ? {}
, treeInfo  ? { prod = {}; dev = {}; }
, metaFiles ? {
    pjsDir    = lib.joinPaths2 sourceInfo.outPath fsInfo.dir;
    pjs       = lib.importJSON ( metaFiles.pjsDir + "/package.json" );
    pjsKey    = "";

    lockDir   = metaFiles.pjsDir;
    plock     =
      if builtins.pathExists ( metaFiles.lockDir + "/package-lock.json" )
      then lib.importJSON ( metaFiles.lockDir + "/package-lock.json" )
      else {};
    plentKey  = "";
    plent     = metaFiles.plock.${metaFiles.plentKey} or {};

    packumentUrl = "https://registry.npmjs.org/${ident}";
    packument    = lib.importJSON (
      builtins.fetchTree {
        type = "file";
        url  = metaFiles.packumentUrl;
      }
    );

    vinfoUrl = "https://registry.npmjs.org/${ident}/${version}";
    vinfo    = lib.importJSON (
      builtins.fetchTree {
        type = "file";
        url  = metaFiles.vinfoUrl;
      }
    );
  }
} @ fields: {
  pkgdef = {
    inherit ident version key;
    inherit ltype depInfo binInfo;
    inherit fetchInfo sourceInfo fsInfo;
    inherit lifecycle sysInfo treeInfo;
    inherit metaFiles;
  };
}
