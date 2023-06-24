# ============================================================================ #
#
# Wrap setup scripts as standalone executables, and as setup-hooks.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs     ? ( import ../inputs ).nixpkgs.flake
, system      ? builtins.currentSystem
, pkgsFor     ? nixpkgs.legacyPackages.${system}
, bash        ? pkgsFor.bash
, coreutils   ? pkgsFor.coreutils
, jq          ? pkgsFor.jq
, findutils   ? pkgsFor.findutils
, nodePackage ? pkgsFor.nodejs-slim
, gnused      ? pkgsFor.gnused
}: let

# ---------------------------------------------------------------------------- #

  scripts = [./run-script.sh ./install-module.sh ./unpatch-shebangs.sh];


# ---------------------------------------------------------------------------- #

in {

  floco-utils = let
    pname   = "floco-utils";
    version = "0.1.1";
  in derivation {
    name = pname + "-" + version;
    inherit
      system pname version scripts bash coreutils findutils jq nodePackage
    ;
    functions        = builtins.path { path = ./functions; };
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
    PATH    = "${coreutils}/bin:${gnused}/bin";
    builder = "${bash}/bin/bash";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      common_path="$bash/bin:$jq/bin";
      mkdir -p "$out/bin" "$out/libexec";
      for script in $scripts; do
        bname="''${script##*/}";
        bname="''${bname:33}";
        case "$bname" in
          unpatch-shebangs.sh)
            spath="$coreutils/bin";
          ;;
          install-module.sh)
            spath="$common_path:$coreutils/bin:$findutils/bin";
          ;;
          run-script.sh)
            spath="$common_path:$nodePackage/bin";
          ;;
          *) spath="$common_path"; ;;
        esac
        inject="export PATH=\\\"\\\$PATH:$spath\\\";";
        inject+=" export FLOCO_FPATH=\\\"$out/libexec/functions\\\";";
        {
          echo "#! $bash/bin/bash";
          tail -n +2 "$script";
        }|sed "s,^# @BEGIN_INJECT_UTILS@\$,$inject," >"$out/bin/$bname";
        chmod +x "$out/bin/$bname";
      done
      cp -r "$functions" "$out/libexec/functions";
    ''];
  };

  floco-hooks = import ./hooks {
    inherit (pkgsFor) makeSetupHook;
    inherit (nixpkgs) lib;
    inherit jq;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
