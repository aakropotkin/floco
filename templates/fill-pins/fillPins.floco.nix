# ============================================================================ #
#
# This expression requires the `floco' `nix-plugin' to be loaded.
#
# ---------------------------------------------------------------------------- #

{ lib ? ( builtins.getFlake "github:aakropotkin/floco" ).lib }: let

# ---------------------------------------------------------------------------- #

  raw = import ./pdefs.nix;


# ---------------------------------------------------------------------------- #

  versionsOf = ident: builtins.attrNames raw.floco.pdefs.${ident};

  satIn = ident: desc:
    builtins.filter ( builtins.semverSat desc ) ( versionsOf ident );

  resolveIn = ident: desc: let
    cmp = a: b: ! ( builtins.lessThan a b );
    res = builtins.head ( builtins.sort cmp ( satIn ident desc ) );
    vs  = versionsOf ident;
  in if ( builtins.length vs ) == 1 then builtins.head vs else res;


# ---------------------------------------------------------------------------- #

  fill = ident: depInfo:
    { pin = resolveIn ident depInfo.descriptor; } // depInfo;

  fillDepInfos = v:
    if ! ( v ? depInfo ) then v else v // {
      depInfo = builtins.mapAttrs fill v.depInfo;
    };


# ---------------------------------------------------------------------------- #

  filled.floco.pdefs =
    builtins.mapAttrs ( _: builtins.mapAttrs ( _: fillDepInfos ) )
                      raw.floco.pdefs;


# ---------------------------------------------------------------------------- #

in {

  inherit
    raw
    versionsOf satIn resolveIn
    fill fillDepInfos
    filled
  ;

  # Use this with `floco eval --raw -f ./fillPins.floco.nix pretty;'
  pretty = lib.generators.toPretty {} filled;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
