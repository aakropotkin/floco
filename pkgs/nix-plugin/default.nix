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

{ nixpkgs   ? ( import ../../inputs ).nixpkgs.flake
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, stdenv    ? pkgsFor.stdenv
, nix-flake ?
  builtins.getFlake "github:NixOS/nix/${builtins.nixVersion or "2.12.0"}"
, boost     ? pkgsFor.boost
, treeFor   ? import ../treeFor { inherit nixpkgs system pkgsFor; }
, semver    ? import ../../fpkgs/semver { inherit nixpkgs system pkgsFor; }
, npm       ? pkgsFor.nodejs-14_x.pkgs.npm
, bash      ? pkgsFor.bash
, pkgconfig ? pkgsFor.pkgconfig
, darwin    ? pkgsFor.darwin
, nix       ? nix-flake.packages.${system}.nix
}: stdenv.mkDerivation {
  inherit bash nix;
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
    nix.dev boost.dev
  ] ++ ( if ! stdenv.isDarwin then [] else [
    darwin.apple_sdk.frameworks.Security
  ] );
  propagatedBuildInputs = [npm treeFor semver];
  nativeBuildInputs     = [pkgconfig];
  buildPhase = ''
    runHook preBuild;
    DEP_CXXFLAGS=( $( pkg-config --libs --cflags nix-expr; ) );
    echo "DEP_CXXFLAGS: ''${DEP_CXXFLAGS[*]}" >&2;
    $CXX -shared -g -fPIC -o "libfloco$libExt" ./*.cc  \
         "''${DEP_CXXFLAGS[@]}"                        \
         ${if stdenv.isDarwin then "-flat_namespace" else ""};
    runHook postBuild;
  '';
  installPhase = ''
    runHook preInstall;
    mkdir -p "$out/libexec" "$out/bin";
    mv -- "./libfloco$libExt" "$out/libexec/libfloco$libExt";
    cat <<EOF >"$out/bin/floco"
    #! $bash/bin/bash
    # A wrapper around Nix that includes the \`libfloco' plugin.
    # First we add runtime executables to \`PATH', then pass off to Nix.
    for p in \$( <"$out/nix-support/propagated-build-inputs"; ); do
      PATH="\$PATH:\$p/bin";
    done
    export PATH;
    exec $nix/bin/nix  \
      --option extra-plugin-files $out/libexec/libfloco$libExt "\$@";
    EOF
    chmod +x "$out/bin/floco";
    runHook postInstall;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
