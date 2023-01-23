# ============================================================================ #
#
# Generates documentation for `<floco>/setup/*' scripts using `help2man'.
#
# ---------------------------------------------------------------------------- #

{ nixpkgs   ? builtins.getFlake "nixpkgs"
, system    ? builtins.currentSystem
, lib       ? nixpkgs.lib
, pkgsFor   ? nixpkgs.legacyPackages.${system}
, help2man  ? pkgsFor.help2man
, gnused    ? pkgsFor.gnused
, bash      ? pkgsFor.bash
, pandoc    ? pkgsFor.pandoc
, coreutils ? pkgsFor.coreutils
}: let

# ---------------------------------------------------------------------------- #

  scripts = {
    run-script     = ../../setup/run-script.sh;
    install-module = ../../setup/install-module.sh;
    npm-plock      = ../../updaters/npm-plock.sh;
    from-registry  = ../../updaters/from-registry.sh;
  };

  genManpage = script: derivation {
    name = let
      s = toString script;
    in ( builtins.head ( builtins.match ".*/(.*)\\.sh" s ) ) + ".1";
    inherit system script bash;
    preferLocalBuild = true;
    allowSubstitutes = ( builtins.currentSystem or "unknown" ) != system;
    PATH    = "${help2man}/bin:${gnused}/bin:${coreutils}/bin";
    builder = "${bash}/bin/bash";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      sed "s,/usr/bin/env bash,$bash/bin/bash," "$script"  \
          > "''${name%.1}.sh";
      chmod +x ./*.sh;
      help2man --no-info -o "$out" ./*.sh;
    ''];
  };

  # This depends on `pandoc' so we definitely want to allow substitutes.
  genOrgmode = script: let
    manpage = genManpage script;
  in derivation {
    name = builtins.replaceStrings [".1"] [".org"] manpage.name;
    inherit system manpage;
    builder = "${bash}/bin/bash";
    PATH    = "${pandoc}/bin:${gnused}/bin:${coreutils}/bin";
    args    = ["-eu" "-o" "pipefail" "-c" ''
      pandoc -f man -t org "$manpage"|sed "s,\`\\([^']\\+\\)',=\\1=,g" > "$out";
    ''];
  };


# ---------------------------------------------------------------------------- #

in {
  run-script-org     = genOrgmode scripts.run-script;
  run-script-man     = genManpage scripts.run-script;

  install-module-org = genOrgmode scripts.install-module;
  install-module-man = genManpage scripts.install-module;

  npm-plock-org = genOrgmode scripts.npm-plock;
  npm-plock-man = genManpage scripts.npm-plock;

  from-registry-org = genOrgmode scripts.from-registry;
  from-registry-man = genManpage scripts.from-registry;
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
