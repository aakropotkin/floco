# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ stdenv, sqlite, pkg-config, nlohmann_json, curlpp, curl }:
stdenv.mkDerivation {
  pname   = "floco-db";
  version = "0.1.0";
  src     = builtins.path {
    path = ../.;
    filter = name: type: let
      bname   = baseNameOf name;
      ignores = ["result" "floco-sql.hh"];
    in ( type == "directory" ) || ( ! ( builtins.elem bname ignores ) );
  };
  nativeBuildInputs = [pkg-config];
  buildInputs       = [sqlite.dev nlohmann_json curlpp curl.dev];
  dontConfigure     = true;
  buildPhase        = ''
    runHook preBuild;
    cd ./cli;
    make;
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
