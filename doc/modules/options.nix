# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib ? import ../../lib {} }:
( lib.evalModules { modules = [../../modules/top]; } ).options


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
