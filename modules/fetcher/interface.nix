# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

  options.fetcher = lib.mkOption {

    description = lib.mdDoc ''
      Abstract fetcher interface to be implemented by `floco.fetcher.*` members.

      The attribute name used for the fetcher may be written to lockfiles
      so choose wisely.
    '';

    type = nt.deferredModuleWith {
      staticModules = [
        ( { ... }: {

# ---------------------------------------------------------------------------- #

          options.pure = lib.mkOption {
            description = lib.mdDoc ''
              Whether fetcher is restricted to pure evaluations.
            '';
            type     = nt.bool;
            readOnly = true;
          };


# ---------------------------------------------------------------------------- #

          #options.systemIFD = lib.mkOption {
          #  description = lib.mdDoc ''
          #    Whether a fetcher is requires system dependant IFD
          #    ( import from derivation ).
          #    If set to true the fetcher may yield different results based on
          #    platform or architecture as a result of using derivations which
          #    set `system` to a non-"unknown" value.

          #    This setting does not restrict the use of derivations which set
          #    `system = "unknown"; builder = "builtin:<NAME>";` such as
          #    `builtins.fetchurl` which uses system-independant IFD.
          #  '';
          #  type     = nt.bool;
          #  readOnly = true;
          #};


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
              The second is the serialized form of `fetchInfo`.

              See Also: deserializeFetchInfo, lockFetchInfo
            '';
            type = nt.functionTo ( nt.functionTo ( nt.either nt.str (
              nt.attrsOf ( nt.nullOr ( nt.oneOf [nt.str nt.int nt.bool] ) )
            ) ) );
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
            type = nt.functionTo ( nt.functionTo ( nt.lazyAttrsOf nt.raw ) );
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
                function = fetchInfo: { outPath = builtins.path fetchInfo; }
              }
            '';
          };


# ---------------------------------------------------------------------------- #

        } )  # End module
      ];  # End `options.fetchers.type.modules'
    };  # End `options.fetchers.type'
    default = {};
  };  # End `options.fetchers'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
