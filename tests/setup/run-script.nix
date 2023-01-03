# ============================================================================ #
#
# Tests the use of `run-scripts.sh' on a trivial project.
#
# This test does not search for `node_modules/.bin' directories in parent paths,
# but does ensure that the flags `-i' and `-I' for `--[no-]ignore-missing'
# works properly.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? ( import ../../inputs ).nixpkgs.flake
, system     ? builtins.currentSystem
, pkgsFor    ? nixpkgs.legacyPackages.${system}
, run_script ? ../../setup/run-script.sh
}: derivation {
  inherit system run_script;
  name    = "run-script-trivial";
  builder = "${pkgsFor.bash}/bin/bash";
  PATH    = "${pkgsFor.coreutils}/bin:${pkgsFor.jq}/bin:${pkgsFor.bash}/bin";
  args = ["-eu" "-o" "pipefail" "-c" ''
    cat <<EOF >package.json
    {
      "name":    "@floco/test",
      "version": "4.2.0",
      "scripts": {
        "build": "touch result",
        "test":
          "if test -r ./result; then echo PASS; else echo FAIL; exit 1; fi"
      }
    }
    EOF
    bash -eu "$run_script" -BPi prebuild build postbuild;
    bash -eu "$run_script" -BPI test|tee "$out";
  ''];
  preferLocalBuild = true;
  allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
