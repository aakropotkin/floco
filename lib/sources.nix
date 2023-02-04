# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  noNixFilter = name: type: let
    bname = baseNameOf name;
  in ( bname != "flake.lock" ) &&
     ( ! ( lib.libfloco.test ".*\\.nix" bname ) ) &&
     ( ( type == "symlink" ) -> (
         ( bname != "result" ) && ( ! ( lib.libfloco.test "result-.*" bname ) )
     ) );


# ---------------------------------------------------------------------------- #

  nodeBasicFilter = name: type:
    ! ( builtins.elem ( baseNameOf name ) [
          "node_modules"
          "package-lock.json" ".npmrc" "npm-debug.log"
          "yarn.lock" ".yarn" ".yarnrc.yml" "yarn-error.log"
          ".tsbuildinfo" ".eslintcache"
        ] );


# ---------------------------------------------------------------------------- #

  noJunkFilter = name: type: let
    bname        = baseNameOf name;
    ignoredNames = [
      ".vscode"
      "Session.vim"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      ".Spotlight-V1000"
      ".Trash-1000"
      ".sass-cache"
    ];
    ignoredPatts = [
      "\\.DS_Store.?"
      "\\._.*"
      ".*~"
      ".*\\.sw[mnop]"
    ];
  in ! ( ( builtins.elem bname ignoredNames ) ||
         ( builtins.any ( p: lib.libfloco.test p bname ) ignoredPatts ) );


# ---------------------------------------------------------------------------- #

  defaultFilter = name: type:
    ( nodeBasicFilter name type ) &&
    ( noJunkFilter name type ) &&
    ( noNixFilter name type );


# ---------------------------------------------------------------------------- #

in {

  inherit noNixFilter nodeBasicFilter defaultFilter;

  cleanLocalSource = path: builtins.path {
    name   = "source";
    filter = defaultFilter;
    inherit path;
  };

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
