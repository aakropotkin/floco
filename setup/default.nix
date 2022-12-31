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
, nodejs    ? pkgsFor.nodejs-14_x
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
    PATH    = "${coreutils}/bin";
    builder = "${bash}/bin/bash";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      mkdir -p "$out/bin";
      for script in $scripts; do
        bname="''${script##*/}";
        bname="''${bname:33}";
        {
          echo "#\! $bash/bin/bash";
          echo "PATH=\"\$PATH:$bash/bin:$coreutils/bin:$findutils/bin\";";
          echo "PATH=\"\$PATH:$jq/bin:$nodejs/bin\";";
          tail -n +2 "$script";
        } >"$out/bin/$bname";
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
