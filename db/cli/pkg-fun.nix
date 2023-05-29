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
        "result"
        "floco-sql.hh"
        "fetch"
        "floco-db"
        "packument"
        "default.nix"
        "pkg-fun.nix"
      ];
    in if type == "directory"
       then bname != "out"
       else ! ( builtins.elem bname ignores );
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
  configurePhase = ''
    runHook preConfigure;
    export PREFIX="$out";
    runHook postConfigure;
  '';
  buildPhase = ''
    runHook preBuild;
    cd ./cli;
    eval "make $makeFlags";
    runHook postBuild;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
