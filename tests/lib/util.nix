# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  getBaseName = x:
    if ( builtins.isString x ) || ( builtins.isPath x ) then baseNameOf x else
    baseNameOf ( x.outPath or x._file or x.file );


# ---------------------------------------------------------------------------- #

  tests = {

    testFlocoConfigsFromDir0 = {
      expr = map getBaseName ( lib.libfloco.flocoConfigsFromDir ./data/proj0 );
      expected = ["floco-cfg.nix"];
    };

    testFlocoConfigsFromDir1 = {
      expr = map getBaseName ( lib.libfloco.flocoConfigsFromDir ./data/proj1 );
      expected = ["pdefs.nix" "foverrides.nix"];
    };

    testFlocoConfigsFromDir2 = {
      expr = map getBaseName ( lib.libfloco.flocoConfigsFromDir ./data/proj2 );
      expected = ["pdefs.json"];
    };

  };


# ---------------------------------------------------------------------------- #

in lib.runTests tests


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
