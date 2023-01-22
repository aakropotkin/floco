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
, npm       ? pkgsFor.nodejs-14_x.pkgs.npm
, gnused    ? pkgsFor.gnused
, nix-flake ?
  builtins.getFlake "github:NixOS/nix/${builtins.nixVersion or "2.12.0"}"
, nix      ? nix-flake.packages.${system}.nix
, flakeRef ? ../.
}: let

# ---------------------------------------------------------------------------- #

  scripts = [./npm-plock.sh ./from-registry.sh];


# ---------------------------------------------------------------------------- #

in {
  floco-updaters = let
    pname   = "floco-updaters";
    version = "0.1.0";
    drv = derivation {
      name = pname + "-" + version;
      inherit
        system pname version scripts flakeRef
        bash coreutils jq nodejs gnused npm nix
      ;
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
            npm-plock.sh|from-registry.sh)
              spath="$npm/bin:$common_path:$gnused/bin:$nix/bin";
              extra=": \\\"\\\''${FLAKE_REF:=$flakeRef}\\\";";
            ;;
            *) extra=""; spath="$common_path"; ;;
          esac
          PATH_INJECT="PATH=\\\"$spath:\\\$PATH\\\";";
          {
            echo "#! $bash/bin/bash";
            tail -n +2 "$script";
          }|sed "s,^# @BEGIN_INJECT_UTILS@\$,$extra\n$PATH_INJECT,"  \
                >"$out/bin/$bname";
          chmod +x "$out/bin/$bname";
        done
      ''];
    };
  in drv // {
    meta.mainProgram = "npm-plock.sh";
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
