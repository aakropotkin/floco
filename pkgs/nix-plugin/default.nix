# ============================================================================ #
#
# Produces a Nix Plugin with some `floco' extensions.
#
# Example plugin invocation ( for a trivial hello world plugin )
# NOTE: use `libhello.dylib' on Darwin.
# $ nix --option plugin-files './result/libexec/libhello.so' eval  \
#       --expr 'builtins.hello'
#   "Hello, World!"
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, stdenv  ? pkgsFor.stdenv
, nix     ?
  builtins.getFlake "github:NixOS/nix/${builtins.nixVersion or "2.12.0"}"
, boost   ? pkgsFor.boost
}: stdenv.mkDerivation {
  pname   = "nix-floco-plugin";
  version = "0.1.0";
  src = builtins.path {
    name = "source";
    path = ./.;
    filter = name: type:
      ( type == "regular" ) && ( ( builtins.match ".*\\.nix" name ) == null );
  };
  libExt      = stdenv.hostPlatform.extensions.sharedLibrary;
  buildInputs = [
    nix.packages.${system}.nix.dev
    boost.dev
  ];
  buildPhase = ''
    runHook preBuild;
    $CXX -shared -o libfloco$libExt -std=c++17  ./*.cc  \
       ${if stdenv.isDarwin then "-undefined suppress -flat_namespace" else ""};
    runHook postBuild;
  '';
  installPhase = ''
    runHook preInstall;
    mkdir -p $out/libexec;
    mv -- ./libfloco$libExt $out/libexec/libfloco$libExt;
    runHook postInstall;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
