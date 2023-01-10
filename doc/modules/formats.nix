# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs ? ( import ../../inputs ).nixpkgs.flake
, lib     ? import ../../lib { inherit (nixpkgs) lib; }
, system  ? builtins.currentSystem
, pkgsFor ? nixpkgs.legacyPackages.${system}
, pandoc  ? pkgsFor.pandoc
, bash    ? pkgsFor.bash
}: let

# ---------------------------------------------------------------------------- #

  docs = options: import ./make-options-doc.nix {
    inherit nixpkgs lib pkgsFor options;
  };

  docbook = { bname, options }: ( docs options ).optionsDocBook // {
    name = bname + "-docbook.xml";
  };


# ---------------------------------------------------------------------------- #

in {

  inherit docbook;

  markdown = { bname, options }: ( docs options ).optionsCommonMark // {
    name = bname + ".md";
  };


# ---------------------------------------------------------------------------- #

  html = { bname, options }: derivation {
    inherit system;
    name    = bname + ".html";
    builder = "${pandoc}/bin/pandoc";
    args = [
      "-o" ( builtins.placeholder "out" )
      "-f" "docbook"
      "-t" "html5"
      ( docbook { inherit bname options; } )
    ];
  };


# ---------------------------------------------------------------------------- #

  #org = { bname, options }: derivation {
  #  inherit system;
  #  name    = bname + ".org";
  #  builder = "${pandoc}/bin/pandoc";
  #  args = [
  #    "-o" ( builtins.placeholder "out" )
  #    "-f" "docbook"
  #    "-t" "org"
  #    ( docbook { inherit bname options; } )
  #  ];
  #};
  org = { bname, options }: derivation {
    inherit system;
    name       = bname + ".org";
    builder    = "${bash}/bin/bash";
    passAsFile = ["text"];
    text       = lib.libdoc.renderOrgFile { inherit options; };
    args       = ["-eu" "-o" "pipefail" "-c" ''
      while read line; do
        echo "$line" >> "$out";
      done <"$textPath";
    ''];
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
