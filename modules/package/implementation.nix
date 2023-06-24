# ============================================================================ #
#
# Expects `pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, options, config, pkgs, pdef, packages, pdefs, nodePackage, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/implementation.nix";

  imports = [./trees/implementation.nix ./targets/implementation.nix];

# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    inherit (pdef) key;

# ---------------------------------------------------------------------------- #

    checkSystemSupport =
      lib.mkDefault ( lib.checkSystemSupportFor pdef );

    systemSupported =
      lib.mkDefault ( config.checkSystemSupport { inherit (pkgs) stdenv; } );


# ---------------------------------------------------------------------------- #

    trees = lib.mkIf ( pdef.treeInfo != null ) {
      supported = lib.mkDefault ( lib.filterAttrs ( k: v: let
          ident   = dirOf v.key;
          version = baseNameOf v.key;
        in ( ! v.optional ) ||
          packages.${ident}.${version}.systemSupported
        ) pdef.treeInfo
      );
    };


# ---------------------------------------------------------------------------- #

    dist = lib.mkDefault ( if pdef.ltype == "file" then null else
      import ../../builders/dist.nix {
        inherit lib nodePackage;
        inherit (pkgs) system bash coreutils jq findutils gnused;
        pkgsFor = pkgs;
        src     = config.built.package;
        pjs = {
          inherit (pdef) version;
          name = pdef.ident;
        };
      } );


# ---------------------------------------------------------------------------- #

    prepared = let
      drv = pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf pdef.ident}-prepared";
        inherit (pdef) version;
        install_module = builtins.path {
          path = ../../setup/install-module.sh;
          recursive = false;
        };
        IDENT             = pdef.ident;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [nodePackage];
        phases            = ["unpackPhase" "installPhase"];
        # TODO: adhere to `files' or `.{npm,git}ignore'
        installPhase = ''
          runHook preInstall;

          rm -f ./package-lock.json;
          if [[ -L ./node_modules ]]; then
            rm ./node_modules;
          elif [[ -d ./node_modules ]]; then
            rm -rf ./node_modules;
          fi

          export HOST_PATH;
          bash -eu "$install_module" -Lst . "$out";

          runHook postInstall;
        '';
        preferLocalBuild = true;
        allowSubstitutes =
          ( builtins.currentSystem or "unknown" ) != pkgs.system;
        dontStrip = true;
      };
    in lib.mkDefault (
      if config.built.enable || config.installed.enable
      then config.installed.package
      else drv
    );


# ---------------------------------------------------------------------------- #

    global = let
      drv = pkgs.stdenv.mkDerivation {
        pname = baseNameOf pdef.ident;
        inherit (pdef) version;
        install_module = builtins.path {
          path = ../../setup/install-module.sh;
          recursive = false;
        };
        IDENT             = pdef.ident;
        NMTREE            = config.trees.global or config.trees.prod;
        src               = config.prepared;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [nodePackage];
        buildCommand      = ''
          runHook preInstall;

          mkdir -p "$out/lib/node_modules/$IDENT";

          if [[ -n "$NMTREE" ]]; then
            cp -pr --reflink=auto --                        \
              "$NMTREE/node_modules"                        \
              "$out/lib/node_modules/$IDENT/node_modules";
          fi

          bash -eu "$install_module" "$src" "$out/lib/node_modules";

          if [[ -d "$out/lib/node_modules/.bin" ]]; then
            mkdir -p "$out/bin";
            for s in "$out/lib/node_modules/.bin/"*; do
              ln -Lsr "$s" "$out/bin/''${s##*/}";
            done
          fi

          runHook postInstall;
        '';
      };
    in lib.mkDefault drv;


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
