{
  config._module.args = let
    system = builtins.currentSystem;
  in {
    pkgs = ( import ../../inputs ).nixpkgs.flake.legacyPackages.${system};
  };
  imports = [./interface.nix];
}
