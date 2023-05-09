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
, sqlite
, ...
}: let
  propagatedBuildInputs = [bash coreutils gnugrep jq nix npm sqlite];
in stdenv.mkDerivation {
  pname    = "floco";
  version  = "0.2.2";
  src      = builtins.path {
    path   = ./src;
    filter = name: type: ( baseNameOf name ) != "site-sql";
  };
  nativeBuildInputs = [makeWrapper];
  dontConfigure     = true;
  dontBuild         = true;
  installPhase      = ''
    mkdir -p                           \
      "$out/bin"                       \
      "$out/share/floco"               \
      "$out/share/floco/site-sql"      \
      "$out/share/zsh/site-functions"  \
    ;
    mv ./libexec "$out/libexec";

    mv ./completion/zsh/_floco "$out/share/zsh/site-functions/";
    rm -rf ./completion;

    mv * "$out/share/floco/";

    cp -- ${builtins.path { path = ../../db; }}/*.sql  \
          "$out/share/floco/site-sql/";

    cp -r -- ${builtins.path { path = ../../lib; }}/*  \
             "$out/share/floco/nix/lib/";

    makeShellWrapper                                              \
      "$out/share/floco/main.sh"                                  \
      "$out/bin/floco"                                            \
      --prefix PATH : "${lib.makeBinPath propagatedBuildInputs}"  \
      --suffix PATH : "$out/libexec"                              \
    ;
   '';
  inherit propagatedBuildInputs;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
