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
      shorthandOnlyDefinesConfig = false;
      modules = [
        ( { options, ... }: let
          inherit (options.key) loc;
        in {
          # Priority prefers low numbers - "low priority" means "big number",
          # "high priority" means "low number".
          # The lowest priority is 1500 which is used by
          # `lib.mkOption { default = <VAL>; }', followed by `lib.mkDefault'
          # which uses 1000.
          # We want this fallback to float around the low end so 1400 is fine.
          config.ident   = lib.mkOverride 1400 ( builtins.elemAt loc oloc );
          config.version =
            lib.mkOverride 1400 ( builtins.elemAt loc ( oloc + 1 ) );
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
