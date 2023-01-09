# ============================================================================ #
#
# Wrap update scripts as standalone executables, and as setup-hooks.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? ( import ../inputs ).nixpkgs.flake
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, bash      ? pkgsFor.bash
, coreutils ? pkgsFor.coreutils
, jq        ? pkgsFor.jq
, nodejs    ? pkgsFor.nodejs-slim-14_x
, gnused    ? pkgsFor.gnused
}: let

# ---------------------------------------------------------------------------- #

  scripts = [./npm-plock.sh];


# ---------------------------------------------------------------------------- #

in {
  floco-updaters = let
    pname   = "floco-updaters";
    version = "0.1.0";
    drv = derivation {
      name = pname + "-" + version;
      inherit system pname version scripts bash coreutils jq nodejs gnused;
      preferLocalBuild = true;
      allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
      PATH    = "${coreutils}/bin:${gnused}/bin";
      builder = "${bash}/bin/bash";
      args    = ["-eu" "-o" "pipefail" "-c" ''
        common_path="$bash/bin:$jq/bin:$coreutils/bin:$nodejs/bin";
        mkdir -p "$out/bin";
        for script in $scripts; do
          bname="''${script##*/}";
          bname="''${bname:33}";
          case "$bname" in
            npm-plock.sh)
              spath="$common_path:$gnused/bin";
            ;;
            *) spath="$common_path"; ;;
          esac
          {
            echo "#! $bash/bin/bash";
            tail -n +2 "$script";
          }|sed "s,^# @BEGIN_INJECT_UTILS@\$,PATH=\\\"\\\$PATH:$spath\\\";,"  \
                >"$out/bin/$bname";
          chmod +x "$out/bin/$bname";
        done
      ''];
    };
  in drv // { meta.mainProgram = "npm-plock.sh"; };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
