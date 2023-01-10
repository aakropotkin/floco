let
  nixpkgs = ( import ../../inputs ).nixpkgs.flake;
  lib     = import ../../lib { inherit (nixpkgs) lib; };
  system  = builtins.currentSystem;
in lib.libdoc.renderOrgFile {
  options = removeAttrs ( lib.evalModules {
    modules = [../../modules/top {
      config._module.args.pkgs = nixpkgs.legacyPackages.${system};
    }];
  } ).options ["_module"];
}
