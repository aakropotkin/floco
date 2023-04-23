# ============================================================================ #
#
# NOTE:
# The `pin' field eventually needs to be moved out of the `depInfo' entry and
# into a project/tree specific record such as `buildPlan'.
# While that migration progresses separating this field allows some parts of
# the codebase to use pins by default, while others can disable them by
# explicitly constructing `depInfoBaseWith { extraEntryModules = []; }'.
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: { options.pin = lib.libfloco.mkPinOption; }


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
