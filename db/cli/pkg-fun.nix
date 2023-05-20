# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ stdenv, sqlite, pkg-config }: stdenv.mkDerivation {
  pname             = "floco-db";
  version           = "0.1.0";
  src               = ./.;
  nativeBuildInputs = [pkg-config];
  buildInputs       = [sqlite.dev];
  dontConfigure     = true;
  buildPhase        = ''
    runHook preBuild;
    $CXX -o "$pname" -std=c++17 $( pkg-config --cflags --libs sqlite3; ) *.cc;
    runHook postBuild;
  '';
  installPhase = ''
    runHook preInstall;
    mkdir -p "$out/bin";
    mv "./$pname" "$out/bin/$pname";
    runHook postInstall;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
