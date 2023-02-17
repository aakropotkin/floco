# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, options, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/fetcher/record.nix";

# ---------------------------------------------------------------------------- #

  options.settings = lib.mkOption {
    description = lib.mdDoc ''
      Settings used to customize a fetcher's behavior.
    '';
    type    = nt.submodule {};
    default = {};
  };


# ---------------------------------------------------------------------------- #

  options.info = lib.mkOption {
    description = lib.mdDoc ''
      Information about a fetcher used to qualify properties such as `pure`,
      or `systemIFD`.

      These properties are `readOnly` from the perspective of the user.
    '';
    type = nt.submodule {

      options.name = lib.mkOption {
        description = lib.mdDoc ''
          The name of the fetcher.

          This name should be unique among all fetchers so that it may be used
          to refer to the fetcher in serialized records.
        '';
        type     = nt.str;
        readOnly = true;
      };

      options.pure = lib.mkOption {
        description = lib.mdDoc ''
          Whether fetcher is restricted to pure evaluations.
        '';
        type     = nt.bool;
        readOnly = true;
      };

      options.systemIFD = lib.mkOption {
        description = lib.mdDoc ''
          Whether a fetcher uses system dependent IFD.

          This indicates that the fetcher may not be used to evaluate
          cross-system derivations.

          This does NOT include the use of `builtins:fetchurl` or other
          builtin derivatons which can be run using `system = "unknown";`.
        '';
        type     = nt.bool;
        readOnly = true;
      };

      options.type = lib.mkOption {
        description = lib.mdDoc ''
          The "generic" type of the fetcher, being one of the types recognized
          by the `<floco>.fetchers.*` members.
        '';
        type     = nt.enum ["tarball" "path" "git" "github" "file"];
        readOnly = true;
      };

    };
  };


# ---------------------------------------------------------------------------- #

  options.lockFetchInfo = lib.mkOption {
    description = lib.mdDoc ''
      A function which fills missing arguments from an "impure"
      `fetchInfo` record to produce a "pure" `fetchInfo` record.

      This routine is used to create lockfiles during discovery phases.
    '';
    type = nt.functionTo ( nt.lazyAttrsOf nt.raw );
    default = fetchInfo: let
      sourceInfo = builtins.fetchTree fetchInfo;
    in ( removeAttrs sourceInfo ["outPath"] ) // fetchInfo;
    example = lib.literalExpression ''
      {
        lockFetchInfo = fetchInfo: let
          outPath = builtins.path {
            inherit (fetchInfo) name path filter recursive;
          };
          sourceInfo = builtins.fetchTree {
            type = "path";
            path = outPath;
          };
        in { sha256 = sourceInfo.narHash; } // fetchInfo;
      }
    '';
  };


# ---------------------------------------------------------------------------- #

  options.serializeFetchInfo = lib.mkOption {
    description = lib.mdDoc ''
      Function which transforms `fetchInfo` into a minimal value to be
      written to a lockile.

      The return value may be a string or attrset of values that are
      coercible to JSON and must not contain absolute filesystem paths.

      This function's output should produce an exact replica of
      `fetchInfo` when passed to `deserializeFetchInfo`.

      This routine accepts two arguemnts.
      The first is `_file` indicating an absolute path the the file
      being serialized to - this is useful for creating relative paths.
      The second is the deserialized form of `fetchInfo`.

      See Also: deserializeFetchInfo, lockFetchInfo
    '';
    type    = nt.functionTo ( nt.functionTo lib.libfloco.jsonValue );
    default = let
      pred = _: v:
        ( builtins.elem ( builtins.typeOf v ) [
            "string" "set" "int" "list" "bool" "null"
          ]
        ) && (
          ( builtins.isString v  ) -> ( ! ( lib.hasPrefix "/" v ) )
        ) && (
          ( builtins.isList v ) -> ( builtins.all pred v )
        );
    in _file: lib.filterAttrsRecursive pred;
  };


# ---------------------------------------------------------------------------- #

  options.deserializeFetchInfo = lib.mkOption {
    description = lib.mdDoc ''
      Function which transforms serialized `fetchInfo` ( an attrset or
      string ) into its attrset form as specified by the
      `fetchInfo` submodule.

      This routine should produce an exact replica of the original
      record before it was serialized by `serializeFetchInfo`.

      This routine accepts two arguemnts.
      The first is `_file` indicating an absolute path the the file
      being deserialized - this is useful for resolving relative paths.
      The second is the serialized form of `fetchInfo`.

      See Also: serializeFetchInfo, lockFetchInfo
    '';
    type    = nt.functionTo ( nt.functionTo ( nt.lazyAttrsOf nt.raw ) );
    default = _file: original: original;
  };


# ---------------------------------------------------------------------------- #

  options.fetchInfo = lib.mkOption {
    description = lib.mdDoc ''
      Submodule type representing arguments passed to fetch function in
      order to produce a `sourceInfo` record.

      This is used to typecheck when parsing lockfiles.
    '';
    type = nt.optionType;
  };


# ---------------------------------------------------------------------------- #

  options.input = lib.mkOption {
    description = lib.mdDoc ''
      String type representing a stringized form of `fetchInfo`.

      This string is analogous to Nix `flakes`' `input.url` strings.
    '';
    type = nt.optionType;
  };


# ---------------------------------------------------------------------------- #

  options.function = lib.mkOption {
    description = lib.mdDoc ''
      Function which performs the fetch.
      This function will be passed a `fetchInfo` record and must return
      a `sourceInfo` record which at a minimum must contain the field
      `outPath` as a member.

      This function must NOT return a raw string.
    '';
    type    = nt.raw;
    example = lib.literalExpression ''
      {
        function = fetchInfo: { outPath = builtins.path fetchInfo; };
      }
    '';
  };


# ---------------------------------------------------------------------------- #

  options.mkFetchInfoOption = lib.mkOption {
    description = lib.mdDoc ''
      Function which creates a `fetchInfo` submodule option.
    '';
    type     = nt.raw;
    readOnly = true;
  };


# ---------------------------------------------------------------------------- #

  options.mkInputOption = lib.mkOption {
    description = lib.mdDoc ''
      Function which creates a `input` submodule option.
    '';
    type     = nt.raw;
    readOnly = true;
  };


# ---------------------------------------------------------------------------- #

  config.mkFetchInfoOption = lib.mkDerivedConfig options.fetchInfo ( fetchInfo:
    lib.mkOption {
      description = lib.mdDoc ''
        Submodule option representing arguments passed to fetch function in
        order to produce a `sourceInfo` record.

        This is used to typecheck when parsing lockfiles.
      '';
      type = fetchInfo;
    }
  );


# ---------------------------------------------------------------------------- #

  config.mkInputOption = lib.mkDerivedConfig options.input ( input:
    lib.mkOption {
      description = lib.mdDoc ''
        String option representing a stringized form of `fetchInfo`.

        This is used to typecheck when parsing lockfiles.
      '';
      type = input;
    }
  );


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
