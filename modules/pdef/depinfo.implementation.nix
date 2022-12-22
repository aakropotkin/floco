# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, ... }: let

  nt = lib.types;

# ---------------------------------------------------------------------------- #
#
# requires             = { id -> desc }
# dependencies         = { id -> desc }
# devDependencies      = { id -> desc }
# peerDependencies     = { id -> desc }
# devDependenciesMeta  = { id -> { optional ::= bool } }
# peerDependenciesMeta = { id -> { optional ::= bool } }
# optionalDependencies = { id -> desc }
# bundleDependencies   = [id]
# bundledDependencies  = bool
#
# ---------------------------------------------------------------------------- #
#
# {
#   descriptor
#   peerDescriptor
#   pin
#   optional
#   peer
#   bundled
#   runtime
#   dev
#   test
#   lint
# }
#
#
# ---------------------------------------------------------------------------- #


in builtins.foldl' lib.recursiveUpdate {} [
  ( builtins.mapAttrs ( _: descriptor: {
      inherit descriptor; runtime = true; dev = true; test = true; lint = true;
    } ) ( ( config.dependencies or {} ) // ( config.requires or {} ) ) )

  ( builtins.mapAttrs ( k: descriptor:
    ( config.devDependenciesMeta.${k} or {} ) // {
      inherit descriptor; runtime = false; dev = true; test = true; lint = true;
    } ) ( config.devDependencies or {} ) )

  ( builtins.mapAttrs ( k: peerDescriptor:
    ( config.peerDependenciesMeta.${k} or {} ) // {
        inherit peerDescriptor; peer = true;
    } ) ( config.peerDependencies or {} ) )

  ( builtins.mapAttrs ( _: descriptor: {
      inherit descriptor;
      optional = true; runtime = true; dev = true; test = true; lint = true;
    } ) ( config.optionalDependencies or {} ) )

  ( builtins.mapAttrs ( _: descriptor: {
      inherit descriptor; bundled = true;
    } ) ( config.bundledDependencies or {} ) )

  ( if ! ( config.bundleDependencies or false ) then {} else
      builtins.mapAttrs ( _: descriptor: {
        inherit descriptor; bundled = true;
      } ) ( config.dependencies or {} ) )
]


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
