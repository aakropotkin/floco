# ============================================================================ #
#
# Wrap setup scripts as standalone executables, and as setup-hooks.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? builtins.getFlake "nixpkgs"
, system    ? builtins.currentSystem
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, bash      ? pkgsFor.bash
, coreutils ? pkgsFor.coreutils
, jq        ? pkgsFor.jq
, findutils ? pkgsFor.findutils
, nodejs    ? pkgsFor.nodejs-slim-14_x
, gnused    ? pkgsFor.gnused
}: let

# ---------------------------------------------------------------------------- #

  scripts = [./run-script.sh ./install-module.sh];


# ---------------------------------------------------------------------------- #

in {
  floco-utils = let
    pname   = "floco-utils";
    version = "0.1.0";
  in derivation {
    name = pname + "-" + version;
    inherit system pname version scripts bash coreutils findutils jq nodejs;
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
    PATH    = "${coreutils}/bin:${gnused}/bin";
    builder = "${bash}/bin/bash";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      common_path="$bash/bin:$jq/bin";
      mkdir -p "$out/bin";
      for script in $scripts; do
        bname="''${script##*/}";
        bname="''${bname:33}";
        case "$bname" in
          install-module.sh)
            spath="$common_path:$coreutils/bin:$findutils/bin";
          ;;
          run-script.sh)
            spath="$common_path:$nodejs/bin";
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
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
