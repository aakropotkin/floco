# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  libLoc    = "floco#lib.libfloco";
  throwFrom = fn: msg: throw "${libLoc}.${fn}: ${msg}";

# ---------------------------------------------------------------------------- #

  depPinsToKeys = x: let
    depInfo = x.depInfo or x;
    deToKey = dIdent: { pin ? throwFrom "depPinsToKeys" "pin not found", ... }:
      "${dIdent}/${pin}";
  in builtins.mapAttrs deToKey depInfo;


# ---------------------------------------------------------------------------- #

  depPinsToDOT = {
    depInfo ? {}
  , key     ? ident + "/" + version
  , ident
  , version
  , ...
  } @ pdef: let
    toDOT = _: depKey: "  " + ''"${depKey}" -> "${key}";'';
  in builtins.attrValues ( builtins.mapAttrs toDOT ( depPinsToKeys pdef ) );


  pdefsToDOT = {
    graphName ? "flocoPackages"
  , pdefs     ? {}
  }: let
    pdefsL = if builtins.isList pdefs then pdefs else
             lib.collect ( v: v ? _export ) pdefs;
    dot    = builtins.concatMap depPinsToDOT pdefsL;
    header = ''
      digraph ${graphName} {
    '';
  in header + ( builtins.concatStringsSep "\n" dot ) + "\n}";


# ---------------------------------------------------------------------------- #

  show       = s: builtins.trace ( "\n" + s + "\n" ) null;
  showPretty = x: show ( lib.generators.toPretty {} x );

  showPrettyCurried = x:
    if ! ( builtins.isFunction x ) then showPretty x else
    y: showPrettyCurried ( x y );


# ---------------------------------------------------------------------------- #

  prettyPrintEscaped = let
    escapeKeywords = let
      keywords = [
        "assert"
        "throw"
        "with"
        "let"
        "in"
        "or"
        "inherit"
        "rec"
        "import"
      ];
      froms = map ( k: " ${k} = " ) keywords;
      tos   = map ( k: " \"${k}\" = " ) keywords;
    in builtins.replaceStrings froms tos;
  in e: ( escapeKeywords ( lib.generators.toPretty {} e ) ) + "\n";


# ---------------------------------------------------------------------------- #

  # Helper used by various routines to apply a function to an attrset of
  # `config.floco.<FIELD>.<NAME>.<VERSION>'.
  # Most commonly used to apply functions to `pdefs' and `packages'.
  runNVFunction = {
    field  ? "pdefs"
  , modify ? true    # Whether the returned value should maintain the same
                     # attrset hierarchy as the input ( performing an update ).
                     # If false, the return value is the result of the function.
  , fn
  }: {
    __functionArgs = {
      config   = true;
      floco    = true;
      ${field} = true;
    };
    __functor = _: args: let
      config = args.config or { floco.${field} = args; };
      floco  = args.floco or config.floco;
      value  = args.${field} or floco.${field};
    in ka: let
      k = if builtins.isAttrs ka then ka else
          assert builtins.isString ka;
          { key = ka; };
      rsl    = fn value k;
      forMod =
        if args ? config then { config.floco.${field} = rsl; } else
        if args ? floco  then { floco.${field} = rsl; } else
        if args ? ${field}  then { ${field} = rsl; } else
        rsl;
    in if modify then forMod else rsl;
  };


# ---------------------------------------------------------------------------- #

  tryImportNixOrJSON' = bpath:
    if builtins.pathExists ( bpath + ".nix" ) then bpath + ".nix" else
    if ! ( builtins.pathExists ( bpath + ".json" ) ) then null else
    lib.modules.importJSON ( bpath + ".json" );

  tryImportNixOrJSON = {
    __functionArgs = { bpath = true; dir = true; bname = true; };
    __functor      = _: args: let
      bpath = if builtins.isString args then args else
              if builtins.isPath args then toString args else
              if args ? outPath then args.outPath else
              args.bpath or ( args.dir + "/" + args.bname );
    in tryImportNixOrJSON' bpath;
  };

  flocoConfigsFromDir = dir: let
    fcfg = tryImportNixOrJSON { inherit dir; bname = "/floco-cfg"; };
    pd   = tryImportNixOrJSON { inherit dir; bname = "/pdefs"; };
    ov   = tryImportNixOrJSON { inherit dir; bname = "/foverrides"; };
  in if fcfg != null then [fcfg] else builtins.filter ( x: x != null ) [pd ov];


# ---------------------------------------------------------------------------- #

  # Runs self application of functor, effectively making it a normal function.
  runFunctor = funk: funk.__functor funk;


# ---------------------------------------------------------------------------- #

    supportedSystems = [
      "x86_64-linux"  "aarch64-linux"  "i686-linux"
      "x86_64-darwin" "aarch64-darwin"
    ];

    eachSupportedSystemMap = fn: let
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc lib.libfloco.supportedSystems );


# ---------------------------------------------------------------------------- #

  # Convenience function that evaluates the `floco' module system on a
  # singleton or list of modules/directories.
  #
  # This has a flexible call style that allows you to indicate `system'.
  # To be explicit use either:
  #   runFloco.<system> <module(s)>
  #   runFloco "<system>" <module(s)>
  # To omit system intentionally:
  #   runFloco.unknown <module(s)>
  #   runFloco "unknown" <module(s)>
  # Or to use the current system as the default, simply:
  #   runFloco <module(s)>
  #
  # In `pure' evaluation mode, attempts to reference `builtins.currentSystem'
  # will fall back to "unknown", meaning you will only be able to use `lib'
  # routines and parts of the module system that do not reference `pkgs'.
  #
  # This is recommended as a convenience routine for interactive use on the
  # CLI, and is explicitly NOT recommended for use scripts or CI automation.
  # For non-interactive use, please use `lib.evalModules' directly, and be
  # explicit about `system', module paths, and handling of JSON files
  # ( use `lib.modules.importJSON' or `lib.libfloco.processImports[Floco]' ).
  runFloco = let
    forSystem = system: cfgs: ( lib.evalModules {
      modules = [
        ../modules/top
        { config.floco.settings = { inherit system; }; }
      ] ++ ( lib.libfloco.processImportsFloco cfgs );
    } ).config.floco;
    bySystem  = ( lib.libfloco.eachSupportedSystemMap forSystem ) // {
      unknown = forSystem "unknown";
    };
  in bySystem // {
    __functor = pf: arg: let
      argIsSystem = builtins.elem arg supportedSystems;
      system      = if argIsSystem then arg else
                    builtins.currentSystem or "unknown";
      fn = pf.${system} or (
        throw "floco#runFloco: Unsupported system: ${system}"
      );
    in if argIsSystem then fn else fn arg;
  };


# ---------------------------------------------------------------------------- #

  pdefToSQL = pdef: let
    bts = b: if b then "TRUE" else "FALSE";
    dev = di: de: ''
      ( '${pdef.key}', '${di}', '${de.descriptor}'
      , ${bts de.runtime}, ${bts de.dev}, ${bts de.optional}
      , ${bts de.bundled} )
    '';
    devs = builtins.attrValues ( builtins.mapAttrs dev pdef.depInfo );
    de   = if pdef.depInfo == {} then "" else ''
      INSERT OR REPLACE INTO depInfoEnts (
       key, ident, descriptor, runtime, dev, optional, bundled
      ) VALUES
    '' + ( builtins.concatStringsSep ", " devs ) + ";";

    pev  = pi: pe: ''
      ( '${pdef.key}', '${pi}', '${pe.descriptor}', ${bts pe.optional} )
    '';
    pevs = builtins.attrValues ( builtins.mapAttrs dev pdef.peerInfo );
    pe   = if pdef.peerInfo == {} then "" else ''
      INSERT OR REPLACE INTO peerInfoEnts (
       key, ident, descriptor, optional
      ) VALUES
    '' + ( builtins.concatStringsSep ", " pevs ) + ";";

    sev  = id: value: "( '${id}', '${value}' )";
    sevs = builtins.attrValues ( builtins.mapAttrs sev pdef.sysInfo.engines );
    se   = if pdef.sysInfo.engines == {} then "" else
      "INSERT OR REPLACE INTO sysInfoEngineEnts ( id, value ) VALUES" +
      ( builtins.concatStringsSep ", " sevs ) + ";";
  in ''
      INSERT OR REPLACE INTO pdefs (
        key, ident, version, ltype, fetcher, fetchInfo
      , lifecycle_build, lifecycle_install
      , binInfo_binDir, binInfo_binPairs
      , fsInfo_dir, fsInfo_gypfile, fsInfo_shrinkwrap
      , sysInfo_cpu, sysInfo_os
      ) VALUES (
        '${pdef.key}', '${pdef.ident}', '${pdef.version}', '${pdef.ltype}'
      , '${pdef.fetcher}', '${builtins.toJSON pdef.fetchInfo}'
      , ${bts pdef.lifecycle.build}, ${bts pdef.lifecycle.install}
      , '${pdef.fsInfo.dir}', ${bts pdef.fsInfo.gypfile}
      , ${bts pdef.fsInfo.shrinkwrap}
      , '${builtins.toJSON pdef.sysInfo.cpu}'
      , '${builtins.toJSON pdef.sysInfo.os}'
      );
    '' + de + pe + se;



# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  inherit
    depPinsToKeys
    depPinsToDOT
    pdefsToDOT

    show showPretty showPrettyCurried

    prettyPrintEscaped

    runNVFunction

    tryImportNixOrJSON
    flocoConfigsFromDir

    runFunctor

    supportedSystems
    eachSupportedSystemMap
    runFloco

    pdefToSQL
  ;


# ---------------------------------------------------------------------------- #

  spp = showPrettyCurried;


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
