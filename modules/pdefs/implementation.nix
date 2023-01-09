# ============================================================================ #
#
# A `options.floco.packages' collection, represented as a list of
# Node.js package/module submodules.
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  options.pdefs = lib.mkOption {
    type = nt.attrsOf ( nt.attrsOf ( nt.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [../pdef/implementation.nix];
    } ) );
  };


# ---------------------------------------------------------------------------- #

  config.pdefs = lib.mkDefault (
    builtins.mapAttrs ( ident: ( builtins.mapAttrs ( version: _: {
      ident   = lib.mkDefault ident;
      version = lib.mkDefault version;
    } ) ) ) options.pdefs
  );  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
