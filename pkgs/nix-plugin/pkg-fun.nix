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

{ stdenv
, boost
, treeFor
, semver
, nodejs
, npm
, bash
, nix
, darwin
}: stdenv.mkDerivation {
  inherit bash nix;
  pname   = "floco-nix";
  version = "0.1.0";
  src = builtins.path {
    name = "source";
    path = ./.;
    filter = name: type:
      ( type == "regular" ) && ( ( builtins.match ".*\\.nix" name ) == null );
  };
  libExt      = stdenv.hostPlatform.extensions.sharedLibrary;
  buildInputs = [nix.dev boost.dev] ++ (
    if stdenv.isDarwin then [darwin.apple_sdk.frameworks.Security] else []
  );
  propagatedBuildInputs = [nodejs npm treeFor semver];
  buildPhase = ''
    runHook preBuild;
    $CXX -shared -o libfloco$libExt -std=c++17  \
      ${if stdenv.isDarwin then "-undefined suppress -flat_namespace" else ""} \
      ./npm-wrap.cc ./npm-fetcher.cc ./progs.cc;
    runHook postBuild;
  '';
  installPhase = ''
    runHook preInstall;
    mkdir -p "$out/libexec" "$out/bin";
    mv -- "./libfloco$libExt" "$out/libexec/libfloco$libExt";
    cat <<EOF >"$out/bin/floco-nix"
    #! $bash/bin/bash
    # A wrapper around Nix that includes the \`libfloco' plugin.
    # First we add runtime executables to \`PATH', then pass off to Nix.
    for p in \$( <"$out/nix-support/propagated-build-inputs"; ); do
      if [[ -d "\$p/bin" ]]; then
        PATH="\$PATH:\$p/bin";
      fi
      if [[ -d "\$p/lib/node_modules" ]]; then
        NODE_PATH="\''${NODE_PATH:+$NODE_PATH:}\$p/lib/node_modules";
      fi
    done
    export PATH NODE_PATH;
    exec "$nix/bin/nix" --plugin-files "$out/libexec/libfloco$libExt" "\$@";
    EOF
    chmod +x "$out/bin/floco-nix";
    runHook postInstall;
  '';
  meta.mainProgram = "floco-nix";
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
