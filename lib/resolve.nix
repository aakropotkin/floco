# ============================================================================ #
#
# URI resolution utilities.
#
# ---------------------------------------------------------------------------- #
#
# Schemas
# -------
#
# * URI
#   - protocol
#     + transport
#     + data
#   - path
#   - authority
#     + userinfo
#       - name
#       - login
#     + host
#     + port
#   - query
#   - fragment
#
# * Protocol
#   - name
#   - parser
#   - serializer
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  resolveTypeRef = types: x: let
    tname = baseNameOf x;
  in if builtins.isList x then map resolveTypeRef types x else
     if ! ( builtins.isString x ) then x else
     if ! ( lib.hasPrefix "#/" x ) then x else
     types.${tname};


# ---------------------------------------------------------------------------- #

  resolveOptionRef = opts: x: let
    tname = baseNameOf x;
  in if ! ( builtins.isString x ) then x else
     if ! ( lib.hasPrefix "#/" x ) then x else
     opts.${tname};


# ---------------------------------------------------------------------------- #

  resolveRefs = opts: let
    ro = resolveOptionRef opts;
  in types: let
    rt = resolveTypeRef types;
  in def:
    if builtins.isString def then rt def else
    assert builtins.isAttrs def;
    if ! ( def ? submodule ) then builtins.mapAttrs ( _: rt ) def else {
      submodule = def.submodule // {
        options = builtins.mapAttrs ( _: ro ) def.submodule.options;
      };
    };


# ---------------------------------------------------------------------------- #

  schemas = {

    protocol_layer = {
      name             = "protocol layer";
      example          = "git";
      type.strMatching = "[[:alpha:]][[:alnum:].-]*";
    };

    protocol_scheme_attrs = {
      name           = "protocol scheme";
      description    = "protocol scheme comprised a transport and data layer";
      type.submodule = {
        options.data      = "#/protocol_layer";
        options.transport = "#/protocol_layer";
      };
      example = { data = "git"; transport = "ssh"; };
    };

    protocol_scheme_string = {
      inherit (schemas.protocol_scheme_attrs) name description;
      type.strMatching = "[[:alpha:]][[:alnum:]+.-]*";
      example          = "git+ssh";
    };

    protocol_scheme = {
      inherit (schemas.protocol_scheme_string) name description example;
      type.either = ["#/protocol_scheme_attrs" "#/protocol_scheme_string"];
    };

  };


# ---------------------------------------------------------------------------- #





# ---------------------------------------------------------------------------- #

in {
  inherit schemas resolveTypeRef resolveOptionRef resolveRefs;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
