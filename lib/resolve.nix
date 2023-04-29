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

  schemas = {

    protocol_layer = {
      name             = "protocol layer";
      example          = "git";
      type.strMatching = "[[:alpha:]][[:alnum:].-]*";
    };

    protocol_scheme_attrs = {
      name           = "protocol scheme";
      description    = "protocol scheme comprised a transport and data layer.";
      type.submodule = {
        options.data = {
          description = "Data format being transported.";
          type        = "protocol_layer";
          default     = "file";
        };
        options.transport = {
          description = ''
            Method, encoding style, or tool used to transport data.

            This is commonly referred to as the "protocol", where the data
            scheme itself is implied or irrelevant.
          '';
          type    = "protocol_layer";
          default = "https";
        };
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
      type.either = ["protocol_scheme_attrs" "protocol_scheme_string"];
    };

  };


# ---------------------------------------------------------------------------- #

in {
  inherit schemas;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
