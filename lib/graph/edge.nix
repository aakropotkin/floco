# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

  libLoc    = "floco#lib.libfloco";
  throwFrom = fn: msg: lib.throw ( libLoc + ":" + fn + ": " + msg );

# ---------------------------------------------------------------------------- #

  edgeKind = nt.enum [
    "prod"
    "dev"
    "optional"
    "peer"
    "peerOptional"
    "workspace"
  ];

  edgeError = nt.enum ["missing" "invalid" "peer_local" "detached" "ok"];


# ---------------------------------------------------------------------------- #

  edgeChecked = e: let
    err = msg: throwFrom "edgeChecked" (
      "edge `${e.config.name}@${e.config.rawSpec}' " + msg
    );
  in if builtins.elem e.config.error [null "ok"] then e else
    if e.error == "missing" then err "is missing from children." else
    if e.error == "invalid" then err "is not satisfied by child." else
    if e.error == "peer_local" then err "is a child, not a peer." else
    if e.error == "detached" then err "has been detached and may be stale." else
    err "unknown error type: ${e.config.error}.";


# ---------------------------------------------------------------------------- #

  edge = nt.submodule ( {
    options
  , config

  , nodes
  , from
  , name
  , type
  , spec
  , ...
  }: {

# ---------------------------------------------------------------------------- #

    config.module._args.nodes = lib.mkOptionDefault {};
    config.module._args.type  = lib.mkOptionDefault "prod";
    config.module._args.from  = lib.mkOptionDefault null;
    config.module._args.spec  = lib.mkOptionDefault "*";

# ---------------------------------------------------------------------------- #

    options.type = nt.mkOption {
      type        = edgeKind;
      description = "The type of the edge.";
      default     =
        lib.mkDerivedConfig options._module.args ( args: args.type );
    };

    options.name = lib.mkIdentOption;


# ---------------------------------------------------------------------------- #

    options.rawSpec = lib.mkOption {
      description = lib.mdDoc ''
        Original package specifier/descriptor declared by `from`.
      '';
      type    = lib.libfloco.descriptor;
      default = lib.mkDerivedConfig options._module.args ( args: args.spec );
    };

    options.accept = lib.mkOption {
      description = lib.mdDoc ''
        Overridden package specifier/descriptor provided by parents'
        `overrides` settings.
      '';
      type    = nt.nullOr lib.libfloco.descriptor;
      default = null;
    };

    options.spec = lib.mkOption {
      description = lib.mdDoc ''
        The final specifier/descriptor of the edge.

        This is derived from `rawSpec` and `accept`.
      '';
      type = lib.libfloco.descriptor;
    };


# ---------------------------------------------------------------------------- #

    options.from = {
      description = lib.mdDoc ''
        Key associated with the parent node that depends on `to`.
      '';
      type    = nt.nullOr lib.libfloco.key;
      default =
        lib.mkDerivedConfig options._module.args ( args: args.from.key );
    };

    options.to = lib.mkKeyOption // {
      description = lib.mdDoc ''
        Key associated with the resolved node that satisfies `spec`.
        `from` "depends on" `to`.
      '';
    };


# ---------------------------------------------------------------------------- #

    options.peerConflicted = lib.mkOption {
      description = lib.mdDoc ''
        Whether a peer dependency is conflicted with a direct dependency.
      '';
      type = nt.bool;
    };

    options.error = lib.mkOption {
      description = lib.mdDoc ''
        The error status of the edge.
      '';
      type    = nt.nullOr edgeError;
      default = nt.null;
    };


# ---------------------------------------------------------------------------- #

    # NOTE: This type differs from `lib.libfloco.specOverrideSet` in that it may
    # contain the key `.` to refer to the current edge's `accept` spec.
    options.overrides = lib.mkOption {
      description = lib.mdDoc ''
        The overrides applicable to this edge's subtree.
        This is an attrset mapping package `ident`s to overridden specs, OR
        a sub-attrset of `{ ".": <SPEC>, <IDENT>: <SPEC|SUB-OVERRIDES>, ... }`.
      '';
      type    = nt.attrsOf lib.libfloco.specOverride;
      default = {};
      example = {
        "foo" = {
          "."   = "^1.0.0";
          "bar" = "^2.0.0";
        };
        "baz" = "^3.0.0";
      };
    };

    options.overridden = lib.mkOption {
      description = lib.mdDoc ''
        Whether the edge's `accept` option is overridden by a parent's
        `overrides` setting.
      '';
      type = nt.bool;
    };


# ---------------------------------------------------------------------------- #

    options.workspace = lib.mkOption {
      description = "Whether the edge is a `workspace` member.";
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.type ( type:
        type == "workspace"
      );
    };

    options.prod = lib.mkOption {
      description = ''Whether the edge is a "production" dependency.'';
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.type ( type:
        type == "prod"
      );
    };

    options.dev = lib.mkOption {
      description = ''Whether the edge is a "development only" dependency.'';
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.type ( type:
        type == "dev"
      );
    };

    options.optional = lib.mkOption {
      description = "Whether the edge is optional.";
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.type ( type:
        builtins.elem type ["optional" "peerOptional"]
      );
    };

    options.peer = lib.mkOption {
      description = "Whether the edge is demanding a `peer` installation.";
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.type ( type:
        builtins.elem type ["peer" "peerOptional"]
      );
    };

    options.bundled = lib.mkOption {
      description = "Whether the edge is bundled.";
      type        = nt.bool;
      default     = lib.mkDerivedConfig options.from ( from:
        ( from != null ) &&
        ( builtins.elem config.name
                        nodes.${from}.config.package.bundledDependencies )
      );
    };


# ---------------------------------------------------------------------------- #

    config.spec = lib.mkDerivedConfig options.accept ( accept:
      if lib.hasPrefix "$" accept then
        throw "Overrides with `$' are not supported."
      else if accept == null then config.rawSpec else accept
    );


# ---------------------------------------------------------------------------- #

  } );  # End `edge'


# ---------------------------------------------------------------------------- #

in {

  inherit
    edgeKind
    edgeError
    edgeChecked
    edge
  ;

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
