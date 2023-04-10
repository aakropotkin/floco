{ lib, pkgs, ... }: {

  floco.packages."@floco/phony"."4.2.0".built.extraNativeBuildInputs = [
    pkgs.cowsay
  ];

  floco.pdefs."@floco/phony"."4.2.0".depInfo.lodash = {
    runtime = lib.mkForce false;
    dev     = lib.mkForce true;
  };

}
