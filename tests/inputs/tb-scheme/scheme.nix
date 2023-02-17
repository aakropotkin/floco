# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, options, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = lib.libfloco;

# ---------------------------------------------------------------------------- #

in {

  options.tbScheme = lib.mkOption { type = lib.libfloco.inputScheme; };

  config.tbScheme = let

    mkInput = attrs: {
      schemeName = lib.mkDerivedConfig options.tbScheme ( s: s.name );
      # `functor` contains all necessary functions, so there is no need to carry
      # a reference to the scheme itself.
      scheme  = null;
      attrs   = { type = "tarball"; } // attrs;
      parent  = null;
      functor = {
        fromURL   = lib.mkDerivedConfig options.tbScheme ( s: s.inputFromURL );
        fromAttrs =
          lib.mkDerivedConfig options.tbScheme ( s: s.inputFromAttrs );
        toURL   = lib.mkDerivedConfig options.tbScheme ( s: s.toURL );
        toAttrs = lib.mkDerivedConfig options.tbScheme ( s: input:
          ( s.fetch input ).input.attrs
        );
        isLocked   = input: ( input.attrs.narHash or null ) != null;
        getType    = _: "tarball";
        getNarHash = lib.mkDerivedConfig options.tbScheme ( s: input:
          if input.isLocked input then input.attrs.narHash else
          ( s.fetch input ).input.attrs.narHash
        );
        getRev         = _: null;
        getRef         = _: null;
        applyOverrides =
          lib.mkDerivedConfig options.tbScheme ( s: s.applyOverrides );
        fetch = lib.mkDerivedConfig options.tbScheme ( s: input: let
          fetched = s.fetch input;
        in {
          tree.actualPath = s.getSourcePath input;
          tree.storePath  = fetched.tree.outPath;
          locked          = fetched.input;
        } );
      };
    };

    inputFromURL = urlRaw: let
      url' = lib.yankN 1 "(tarball[+:]?)?(.*)" urlRaw;
      url  = let
        n = builtins.match "(file:/?)?(/.*)" url';
      in if n == null then url' else builtins.elemAt n 1;
      m    = builtins.match ".*([&?](narHash|sha256)=([^&]+)).*" url;
      nh   = if m == null then null else builtins.elemAt m 2;
      nh'  = if nh == null then {} else { narHash = nh; };
    in mkInput ( {
      url = if m == null then url else
            builtins.replaceStrings [( builtins.head m )] [
              ( if ( ( builtins.substring 0 1 ( builtins.head m ) ) == "&" ) ||
                   ( lib.hasSuffix nh url )
                then ""
                else "?" )
            ] url;
    } // nh' );

  in {
    name = "tarball";

    inherit inputFromURL;

    inputFromAttrs = attrs: let
      nh  = attrs.narHash or attrs.sha256 or attrs.outputHash or null;
      nh' = if nh == null then {} else { narHash = nh; };
      fu  = inputFromURL attrs.url;
    in mkInput ( fu.attrs // nh' );

    toURL = input: let
      pre = if lib.test "(file|https)://.*" input.attrs.url then "tarball+" else
            "tarball:";
    in
      if ! input.isLocked input then pre + input.attrs.url else
      if lib.test ".*?.*" input.attrs.url
      then pre + input.attrs.url + "&narHash=" + input.attrs.narHash
      else pre + input.attrs.url + "?narHash=" + input.attrs.narHash;

    getSourcePath = input: let
      p = lib.yank "(/[^?]*)(\\?.*)?" input.attrs.url;
    in if p == null then null else /. + p;

    fetch = input: let
      sourceInfo = builtins.fetchTree input.attrs;
    in {
      tree  = sourceInfo;
      input = input // {
        attrs = { inherit (sourceInfo) narHash; } // input.attrs;
      };
    };

  };  # End `config.tbScheme'

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
