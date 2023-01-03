# ============================================================================ #
#
# Tests the use of `install-module.sh' on a trivial project: `lodash'.
#
# This test is the "softball" case since this package has no `bin' executables,
# and its default permissions when unpacked are suitable for consumption.
#
# The only real aspect of this test we may want to pay attention to is how
# file modification time and file ownership are treated once installed; however
# this test case will not PASS/FAIL based on these values.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? ( import ../../inputs ).nixpkgs.flake
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, lodash  ? builtins.fetchTree {
    type    = "tarball";
    url     = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
    narHash = "sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=";
  }
, install_module ? ../../setup/install-module.sh
}: derivation {
  inherit system install_module lodash;
  name    = "install-module-lodash";
  builder = "${pkgsFor.bash}/bin/bash";
  PATH    = "${pkgsFor.coreutils}/bin:${pkgsFor.findutils}/bin:" +
            "${pkgsFor.jq}/bin:${pkgsFor.bash}/bin";
  args = ["-eu" "-o" "pipefail" "-c" ''
    bash -eu "$install_module" "$lodash" "$out/node_modules";
    ls -Rla "$out" >&2;
  ''];
  preferLocalBuild = true;
  allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
