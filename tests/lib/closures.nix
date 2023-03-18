# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  mod = lib.evalModules {
    modules = [
      ../../modules/top
      ./data/pacote/floco-cfg.nix
    ];
  };

  inherit (mod.config.floco) pdefs;

# ---------------------------------------------------------------------------- #

in lib.runTests {

# ---------------------------------------------------------------------------- #

  testMkDepInfoEntryPred0 = {
    expr = let
      proc = args: ( lib.libfloco.mkDepInfoEntryPred args ) // {
        __functor = null;
      };
    in map proc [
      {}
      { runtime = true; }
      { runtime = false; dev = true; }
      { runtime = false; dev = null; }
    ];
    expected = [
      { mask = {}; __functor = null; }
      { mask.runtime = true; __functor = null; }
      { mask = { runtime = false; dev = true; }; __functor = null; }
      { mask.runtime = false; __functor = null; }
    ];
  };

  testMkDepInfoEntryPred1 = {
    expr = let
      p0 = lib.libfloco.mkDepInfoEntryPred {};
      p1 = lib.libfloco.mkDepInfoEntryPred { runtime = true; };
      p2 = lib.libfloco.mkDepInfoEntryPred { runtime = true; dev = false; };
      p3 = lib.libfloco.mkDepInfoEntryPred { runtime = true; dev = null; };

      def = props: {
        runtime  = false;
        dev      = true;
        optional = false;
        bundled  = false;
      } // props;

      run = pred: props: pred ( def props );
    in [
      ( run p0 {} )                                 # => true
      ( run p0 { runtime = true; } )                # => true
      ( run p0 { dev = false; } )                   # => true
      ( run p0 { foo = false; } )                   # => true
      ( run p1 { runtime = true; } )                # => true
      ( run p1 { runtime = false; } )               # => false
      ( run p1 { runtime = false; foo = false; } )  # => false
      ( run p1 { runtime = true; foo = false; } )   # => true
      ( run p2 { runtime = true; dev = false; } )   # => true
      ( run p2 { runtime = true; dev = true; } )    # => false
      ( run p3 { runtime = true; dev = false; } )   # => true
      ( run p3 { runtime = true; dev = true; } )    # => true
      ( run p3 { runtime = false; dev = false; } )  # => false
      ( run p3 { runtime = false; dev = true; } )   # => false
    ];
    expected = [
      true true true true true false false true true false true true false false
    ];
  };


# ---------------------------------------------------------------------------- #

  testDepInfoEntryPred0 = {
    expr = map lib.libfloco.depInfoEntryPred.check [
      { runtime = true; }
      { dev = true; foo = "hi"; }
      {}
      ( _: true )
      ( _: null )
      { __functor = self: _: true; mask = {}; }
      { __functor = self: _: true; mask.foo = false; }
      { __functor = self: _: true; foo = {}; }
    ];
    expected = [
      true
      false
      true
      true
      false
      true
      false
      true
    ];
  };


# ---------------------------------------------------------------------------- #

  testPdefClosureCached = let
    pcf = lib.libfloco.runType lib.libfloco.pdefClosureCachedFunctor {
      _module.args = { inherit pdefs; };
    };
    # Make sure it still works as a regular closure functor when the cache is
    # completely empty.
    ckeys = map ( v: v.ident + "/" + v.version )
                ( builtins.tail ( pcf "pacote/13.3.0" ) );
    # Select `n' members of `lst' skipping an equal number of members
    # between selections.
    # This is essentially a non-random way to pick `n' arbitrary members.
    pickN = lst: n: let
      c    = ( builtins.length lst ) / n;
      pull = x: builtins.elemAt lst ( x * c );
    in if c <= 1 then lst else builtins.genList pull n;
    # `pcf' with 5 cache entries
    pcfCached = builtins.foldl' ( f: f.__cacheChild f ) pcf ( pickN ckeys 5 );
    cckeys    = map ( v: v.ident + "/" + v.version )
                    ( builtins.tail ( pcfCached "pacote/13.3.0" ) );
  in {
    expr = {
      nents  = builtins.length ( builtins.attrNames pcfCached.payload.cache );
      keysEq = ( builtins.sort builtins.lessThan ckeys ) ==
               ( builtins.sort builtins.lessThan cckeys );
    };
    expected = {
      nents  = 5;
      keysEq = true;
    };
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
