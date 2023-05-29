# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ stdenv
, sqlite
, pkg-config
, nlohmann_json
, argparse
, nix
, boost
}: stdenv.mkDerivation {
  pname   = "floco-db";
  version = "0.1.0";
  src     = builtins.path {
    path = ../.;
    filter = name: type: let
      bname   = baseNameOf name;
      ignores = [
        "result" "floco-sql.hh" "fetch" "floco-db" "default.nix" "pkg-fun.nix"
      ];
    in ( type == "directory" ) || ( ! ( builtins.elem bname ignores ) );
  };
  libExt            = stdenv.hostPlatform.extensions.sharedLibrary;
  nativeBuildInputs = [pkg-config];
  buildInputs       = [
    sqlite.dev nlohmann_json argparse nix.dev boost
  ];
  makeFlags = [
    "boost_CFLAGS=-I${boost}/include"
    "libExt=${stdenv.hostPlatform.extensions.sharedLibrary}"
  ];
  dontConfigure     = true;
  buildPhase        = ''
    runHook preBuild;
    cd ./cli;
    eval "make $makeFlags";
    runHook postBuild;
  '';
  installPhase = ''
    runHook preInstall;
    mkdir -p "$out/bin" "$out/lib";
    mv "./$pname" "$out/bin/$pname";
    mv "./libflocodb"* "$out/lib/";
    runHook postInstall;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
