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
, nlohmann_json
, treeFor
, semver
, nodejs
, npm
, bash
, nix
, pkg-config
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
  libExt            = stdenv.hostPlatform.extensions.sharedLibrary;
  nativeBuildInputs = [pkg-config];
  buildInputs       = [nix.dev boost.dev] ++ (
    if stdenv.isDarwin then [darwin.apple_sdk.frameworks.Security] else []
  );
  propagatedBuildInputs = [nix nodejs npm treeFor semver];
  # NOTE: Nix 2.12.x requires `-lnixfetchers' to be linked explicitly.
  # npm 9.3.1
  buildPhase = ''
    runHook preBuild;
    $CXX                                                                       \
      -o "libfloco$libExt"                                                     \
      -fPIC                                                                    \
      -shared                                                                  \
      -I${nix.dev}/include                                                     \
      -I${nix.dev}/include/nix                                                 \
      -I${boost.dev}/include                                                   \
      -I${nlohmann_json}/include                                               \
      -include ${nix.dev}/include/nix/config.h                                 \
      $( pkg-config --cflags nix-main nix-store nix-expr; )                    \
      ${if stdenv.isDarwin then "-undefined suppress -flat_namespace" else ""} \
      ./npm-wrap.cc ./npm-fetcher.cc ./progs.cc                                \
      -Wl,--as-needed                                                          \
      $( pkg-config --libs nix-store nix-expr nix-cmd; )                       \
      -lnixfetchers                                                            \
      -Wl,--no-as-needed                                                       \
    ;
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
