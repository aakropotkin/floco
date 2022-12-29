{ nixpkgs    ? builtins.getFlake "nixpkgs"
, system     ? builtins.currentSystem
, pkgsFor    ? nixpkgs.legacyPackages.${system}
, run_script ? ../../setup/run-script.sh
}: derivation {
  inherit system run_script;
  name    = "run-script-trivial";
  builder = "${pkgsFor.bash}/bin/bash";
  PATH    = "${pkgsFor.coreutils}/bin:${pkgsFor.jq}/bin:${pkgsFor.bash}/bin";
  args = ["-euc" ''
    set -o pipefail;
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
    bash -c "$run_script -BPi prebuild build postbuild";
    bash -c "$run_script -BPI test"|tee "$out";
  ''];
  preferLocalBuild = true;
  allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
}
