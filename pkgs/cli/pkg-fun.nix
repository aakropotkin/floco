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
, npm
, ...
}: let
  propagatedBuildInputs = [bash coreutils gnugrep jq nix npm];
in stdenv.mkDerivation {
  pname             = "floco";
  version           = "0.1.0";
  src               = builtins.path { path = ./src; };
  nativeBuildInputs = [makeWrapper];
  dontConfigure     = true;
  dontBuild         = true;
  installPhase      = ''
    mkdir -p "$out/bin" "$out/share/zsh/site-functions" "$out/libexec";
    mv ./completion/zsh/_floco "$out/share/zsh/site-functions/";
    rm -rf ./completion;
    rm -f ./test-common.sh;
    mv * "$out/libexec";
    makeShellWrapper                                              \
      "$out/libexec/main.sh"                                      \
      "$out/bin/floco"                                            \
      --prefix PATH : "${lib.makeBinPath propagatedBuildInputs}"  \
    ;
    cp -r -- ${builtins.path { path = ../../lib; }}/* "$out/libexec/lib/";
   '';
  inherit propagatedBuildInputs;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
