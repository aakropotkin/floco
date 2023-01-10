# ============================================================================ #
#
# Expects `config.pdef' to be provided.
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, floco, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  imports = [./trees/implementation.nix ./targets/implementation.nix];

# ---------------------------------------------------------------------------- #

  options.pdef = lib.mkOption {
    type = nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [../pdef/implementation.nix];
    };
  };


# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    inherit (config.pdef) key;

# ---------------------------------------------------------------------------- #

    checkSystemSupport =
      lib.mkDefault ( lib.checkSystemSupportFor config.pdef );

    systemSupported =
      lib.mkDefault ( config.checkSystemSupport { inherit (pkgs) stdenv; } );


# ---------------------------------------------------------------------------- #

    trees = lib.mkIf ( config.pdef.treeInfo != null ) {
      supported = lib.mkDefault ( lib.filterAttrs ( k: v: let
          ident   = dirOf v.key;
          version = baseNameOf v.key;
        in ( ! v.optional ) ||
          floco.packages.${ident}.${version}.systemSupported
        ) config.pdef.treeInfo
      );
    };


# ---------------------------------------------------------------------------- #

    dist = lib.mkDefault ( if config.pdef.ltype == "file" then null else
      import ../../builders/dist.nix {
        inherit lib;
        inherit (pkgs) system bash coreutils findutils;
        pkgsFor = pkgs;
        src     = config.built.package;
        pjs = {
          inherit (config.pdef) version;
          name = config.pdef.ident;
        };
      } );


# ---------------------------------------------------------------------------- #

    prepared = let
      drv = pkgs.stdenv.mkDerivation {
        pname = "${baseNameOf config.pdef.ident}-prepared";
        inherit (config.pdef) version;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        src               = config.source;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
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
        pname = baseNameOf config.pdef.ident;
        inherit (config.pdef) version;
        install_module    = ../../setup/install-module.sh;
        IDENT             = config.pdef.ident;
        NMTREE            = config.trees.prod;
        src               = config.prepared;
        nativeBuildInputs = [pkgs.jq];
        buildInputs       = [pkgs.nodejs-14_x];
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
