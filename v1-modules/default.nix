# ============================================================================ #
#
# This file is a "polymodule", meaning it can be used as a module or as a
# regular function.
#
# To use it as a module, it will simply emit its values with `option`
# declarations of type `raw`.
# With that in mind, it isn't particularly useful to consume it as a module
# in its current state.
#
# Eventually it will become a more useful module with proper typing, and when
# that time comes I'd rather avoid rewriting a shitload of test cases, so those
# are already using `lib.evalModules' to consume it.
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../lib {}, config ? {}, ... } @ args: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  stage0 = lib.evalModules {
    modules = [
      ./stage0.nix
      {
        config = builtins.intersectAttrs {
          settings = true;
          env      = true;
          inputs   = true;
        } config;
      }
    ];
  };


# ---------------------------------------------------------------------------- #

  stage1 = lib.evalModules {
    modules = [
      ./stage1.nix
      {
        config = builtins.intersectAttrs {
          settings = true;
          records  = true;
          fetchers = true;
          builders = true;
          utils    = true;
        } config;
      }
    ];
    specialArgs = {
      inherit (stage0.config.env) lib pkgs;
      inherit (stage0.config) env inputs;
    };
  };


# ---------------------------------------------------------------------------- #

  outputs = {
    inherit
      lib
      config
      stage0
      stage1
    ;
  };

  asModule = {
    options = builtins.mapAttrs ( _: _: lib.mkOption { type = nt.raw; } )
                                outputs;
    config = outputs;
  };


# ---------------------------------------------------------------------------- #

in if args ? specialArgs then asModule else outputs


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
