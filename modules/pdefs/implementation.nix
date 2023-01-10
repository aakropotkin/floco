# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt   = lib.types;
  oloc = builtins.length options.pdefs.loc;

in {

# ---------------------------------------------------------------------------- #

  options.pdefs = lib.mkOption {
    type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [
        ( { options, ... }: let
          inherit (options.key) loc;
        in {
          config.ident   = lib.mkOverride 10 ( builtins.elemAt loc oloc );
          config.version =
            lib.mkOverride 10 ( builtins.elemAt loc ( oloc + 1 ) );
        } )
        ../pdef/implementation.nix
      ];
    } ) );
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
