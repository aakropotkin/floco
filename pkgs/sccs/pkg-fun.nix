# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ stdenv
, nlohmann_json
}: stdenv.mkDerivation {
  pname       = "sccs";
  version     = "0.1.0";
  buildInputs = [
    nlohmann_json
  ];
  configurePhase = ''
    runHook preConfigure;

    export NLOHMANN_JSON_CXXFLAGS="-I${nlohmann_json}/include";
    export NLOHMANN_JSON_LDFLAGS=;
    export PREFIX="$out";

    runHook postConfigure;
  '';
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
