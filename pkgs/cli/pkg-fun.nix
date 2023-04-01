# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib
, stdenv
, bash
, coreutils
, gnugrep
, jq
, makeWrapper
, nix
, ...
}: stdenv.mkDerivation {
  pname   = "floco";
  version = "0.1.0";
  src     = builtins.path { path = ./src; };
  nativeBuildInputs     = [makeWrapper];
  propagatedBuildInputs = [bash coreutils gnugrep jq nix];
  dontConfigure         = true;
  dontBuild             = true;
  installPhase          = ''
    mkdir -p "$out/bin" "$out/share/zsh/site-functions" "$out/libexec";
    mv ./completion/zsh/_floco "$out/share/zsh/site-functions/";
    rm -rf ./completion;
    rm -f ./test-common.sh;
    mv * "$out/libexec";
    makeShellWrapper                                                        \
      "$out/libexec/main.sh"                                                \
      "$out/bin/floco"                                                      \
      --prefix PATH : "${lib.makeBinPath [bash coreutils gnugrep jq nix]}"  \
    ;
    cp -- ${builtins.path { path = ../../lib; }}/*.nix "$out/libexec/";
   '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
