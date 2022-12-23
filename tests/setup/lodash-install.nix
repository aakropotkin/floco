{ nixpkgs ? builtins.getFlake "nixpkgs"
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
  args = ["-exc" ''
    install-module() { bash "$install_module" "$@"; };
    install-module "$lodash" "$out/node_modules";
    ls -Rla "$out" >&2;
  ''];
  preferLocalBuild = true;
  allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
}
