# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  pdefClosure' = pdefs: keylike: let
    mkNode = builtins.intersectAttrs {
      key     = true; ident    = true; version  = true;
      depInfo = true; peerInfo = true;
    };
    get = ident: { pin, ... }: let
      full = lib.libfloco.getPdef { inherit pdefs; } {
        inherit ident; version = pin;
      };
    in mkNode full;
    operator = pdef: builtins.attrValues ( builtins.mapAttrs get pdef.depInfo );
  in builtins.genericClosure {
    startSet = operator ( mkNode ( lib.libfloco.getPdef pdefs keylike ) );
    inherit operator;
  };

  pdefClosure = {
    config ? { floco.pdefs = pa; }
  , floco  ? config.floco
  , pdefs  ? floco.pdefs
  , ...
  } @ pa: keylike: pdefClosure' pdefs keylike;


# ---------------------------------------------------------------------------- #

in {

  inherit
    pdefClosure
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
