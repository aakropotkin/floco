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
          "node_modules" "package-lock.json" "yarn.lock"
          ".yarn" ".yarnrc.yml" ".npmrc"
        ] );


# ---------------------------------------------------------------------------- #

  defaultFilter = name: type:
    ( noNixFilter name type ) && ( nodeBasicFilter name type );


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
