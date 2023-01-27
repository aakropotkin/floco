# ============================================================================ #
#
# Arguments used to fetch a source tree or file.
#
# ---------------------------------------------------------------------------- #

{ lib, config, fetcher, ... } @ fetchers: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;
  ft = import ../types.nix { inherit lib; };

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/fetchers/fetcher/fetchTarballDrv/implementation.nix";

# ---------------------------------------------------------------------------- #

  options.fetchTarballDrv = lib.mkOption {
    type = nt.submodule {
      imports = [fetcher];

      options.serializerStyle = lib.mkOption {
        description = lib.mdDoc ''
          Preferred serialization style used to write lockfiles.
          - `string` writes `fetchInfo` to a URI string equivalent to the one
            used for `flake` inputs.
          - `attrs` emits `fetchInfo` as an attribute set, dropping some fields
            if they can be inferred by `deserializeFetchInfo`.

          Note that the function `deserializeFetchInfo` must be able to read
          either form regardless of how this option is set.
        '';
        type    = nt.enum ["string" "attrs"];
        default = "attrs";
        example = "string";
      };

      options.serializeFetchInfo_string = lib.mkOption {
        type     = nt.functionTo ( nt.functionTo nt.str );
        internal = true;
        visible  = false;
      };
      options.serializeFetchInfo_attrs = lib.mkOption {
        type     = nt.functionTo ( nt.functionTo ( nt.attrsOf lib.jsonAtom ) );
        internal = true;
        visible  = false;
      };

    };  # End `options.fetchTarballDrv.type'
  };


# ---------------------------------------------------------------------------- #

  config.fetchTarballDrv = {

# ---------------------------------------------------------------------------- #

    inherit (config) pure;

    function = lib.mkDefault ( args: let
      dropArExt = n: let
        tarball_ext_p = "\\.(tar(\\.[gx]z)?|gz|tgz|zip|xz|bz(ip)?)";
        m = builtins.match "(.*)${tarball_ext_p}(#.*)?" n;
      in if m == null then n else builtins.head m;
      drv = derivation {
        name       = dropArExt ( baseNameOf args.url );
        outputHash =
          args.narHash or
          ( config.fetchTarballDrv.lockFetchInfo args ).narHash;
        inherit (args) url;
        builder          = "builtin:fetchurl";
        system           = "builtin";
        outputHashMode   = "recursive";
        outputHashAlgo   = "sha256";
        unpack           = false;
        executable       = false;
        preferLocalBuild = true;
        impureEnvVars = [
          "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
        ];
        urls = [args.url];
      };
    in {
      outPath = builtins.fetchTarball ( "file:" +
        ( builtins.unsafeDiscardStringContext drv.outPath )
      );
      narHash = drv.outputHash;
    } );


# ---------------------------------------------------------------------------- #

    serializeFetchInfo_string =
      lib.mkDefault config.fetchTree_file.serializeFetchInfo_string;
    serializeFetchInfo_attrs =
      lib.mkDefault config.fetchTree_file.serializeFetchInfo_attrs;

    serializeFetchInfo = lib.mkDefault (
      if config.fetchTarballDrv.serializerStyle == "string"
      then config.fetchTarballDrv.serializeFetchInfo_string
      else config.fetchTarballDrv.serializeFetchInfo_attrs
    );

    lockFetchInfo = lib.mkDefault config.fetchTree_file.lockFetchInfo;

    deserializeFetchInfo =
      lib.mkDefault config.fetchTree_file.deserializeFetchInfo;

    fetchInfo = config.fetchTree_file.fetchInfo;


# ---------------------------------------------------------------------------- #

  };  # End `config.fetchTarballDrv'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
