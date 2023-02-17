# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

  jsonAtom = ( nt.nullOr ( nt.oneOf [nt.str nt.bool nt.int nt.float] ) ) // {
    name        = "JSON atom";
    description = "JSON `null`, `string`, `bool`, or `number` value";
  };

  jsonValue = ( nt.oneOf [
    lib.libfloco.jsonAtom
    ( nt.listOf jsonValue )
    ( nt.attrsOf jsonValue )
  ] ) // {
    name        = "JSON value";
    description = "JSON compatible value";
  };


# ---------------------------------------------------------------------------- #

  version = let
    da_c      = "[[:alpha:]-]";
    dan_c     = "[[:alnum:]-]";
    num_p     = "(0|[1-9][[:digit:]]*)";
    part_p    = "(${num_p}|[0-9]*${da_c}${dan_c}*)";
    core_p    = "${num_p}(\\.${num_p}(\\.${num_p})?)?";
    tag_p     = "${part_p}(\\.${part_p})*";
    build_p   = "${dan_c}+(\\.[[:alnum:]]+)*";
    version_p = "${core_p}(-${tag_p})?(\\+${build_p})?";
  in ( nt.strMatching version_p ) // {
    name        = "version";
    description = "semantic version number";
  };


# ---------------------------------------------------------------------------- #

  uri = nt.str // {
    name        = "URI";
    description = "uniform resource identifier";
  };


# ---------------------------------------------------------------------------- #

  descriptor = ( nt.either lib.libfloco.version lib.libfloco.uri ) // {
    name        = "package descriptor";
    description = "version or URI";
  };


# ---------------------------------------------------------------------------- #

  ident = ( nt.strMatching "(@[^@/]+/)?[^@/]+" ) // {
    name        = "package identifier";
    description = "package identifier/name";
  };


# ---------------------------------------------------------------------------- #

  key = nt.str // {
    name        = "package key";
    description = "unique package identifier";
  };


# ---------------------------------------------------------------------------- #

  ltype = ( nt.enum ["file" "link" "dir" "git"] ) // {
    name        = "lifecycle type";
    description = "lifecycle type as recognized by `npm`";
    merge       = lib.libfloco.mergePreferredOption {
      compare = a: b:
        if a == "file" then true else if b == "file" then false else
        if a == "dir"  then true else if b == "dir"  then false else
        if a == "link" then true else if b == "link" then false else
        true;
    };
  };


# ---------------------------------------------------------------------------- #

  # `package.json', `package-lock.json', and other non-`floco' metadata.
  depAttrs = nt.attrsOf lib.libfloco.descriptor;
  depMetas = nt.attrsOf ( nt.attrsOf nt.bool );


# ---------------------------------------------------------------------------- #

  relpath = ( nt.strMatching "[^/[:space:]].*" ) // {
    name        = "relative path";
    description = "relative path without leading slash";
  };

  storePath = ( nt.strMatching ( builtins.storeDir + "/.*" ) ) // {
    name        = "nix store path";
    description = "path to a file/directory in the nix store";
  };


# ---------------------------------------------------------------------------- #

  binPairs = nt.attrsOf lib.libfloco.relpath;
  pjsBin   = nt.either lib.libfloco.relpath lib.libfloco.binPairs;


# ---------------------------------------------------------------------------- #

  sha256_hash = ( nt.strMatching "[[:xdigit:]]{64}" ) // {
    name        = "SHA-256 hex";
    description = "SHA-256 hash (hexadecimal)";
  };
  sha256_sri = ( nt.strMatching "sha256-[a-zA-Z0-9+/]{42,44}={0,2}" ) // {
    name        = "SHA-256 SRI";
    description = "SHA-256 hash (SRI)";
  };
  narHash = lib.libfloco.sha256_sri // {
    name        = "narHash";
    description = "NAR hash (SHA256 SRI)";
  };


# ---------------------------------------------------------------------------- #

  rev = ( nt.strMatching "[[:xdigit:]]{40}" ) // {
    name        = "rev";
    description = "SHA-1 revision (hexadecimal)";
  };
  short_rev = ( nt.strMatching "[[:xdigit:]]{7}" ) // {
    name        = "short rev";
    description = "first 7 characters of SHA-1 revision (hexadecimal)";
  };


# ---------------------------------------------------------------------------- #

  tree = nt.submodule {
    options = {
      storePath  = lib.mkOption {
        description = "path to fetched tree in the nix store";
        type        = lib.libfloco.storePath;
      };
      actualPath = lib.mkOption {
        description = "original path outside of the nix store (if any)";
        type        = nt.nullOr nt.path;
        default     = null;
      };
    };
  };


# ---------------------------------------------------------------------------- #

  inputScheme = nt.submodule {
    options = {

      name = lib.mkOption {
        description = lib.mdDoc ''
          unique name of the input scheme used to refer to this input scheme in
          `input` records.
        '';
        type = nt.str;
      };

      inputFromURL = lib.mkOption {
        description = lib.mdDoc ''
          Function which attempts to parse a URL into an `input`.

          May return `null` if the URL is not recognized by this input scheme
          or is otherwise unfetchable.
          This allows other input schemes to be tried.
       '';
        type = nt.nullOr ( nt.functionTo ( nt.nullOr lib.libfloco.input ) );
      };

      inputFromAttrs = lib.mkOption {
        description = lib.mdDoc ''
          Function which attempts to transform an attrset into an `input`.

          May return `null` if the attrsets' contents are not recognized by this
          input scheme or is otherwise unfetchable.
          This allows other input schemes to be tried.
       '';
        type = nt.nullOr ( nt.functionTo ( nt.nullOr lib.libfloco.input ) );
      };

      toURL = lib.mkOption { type = nt.functionTo lib.libfloco.uri; };

      applyOverrides = lib.mkOption {
        description = lib.mdDoc ''
          Function which applies overrides to the input.

          Overrides are an attrset of `{ input, rev ? null, ref ? null }` which
          may be applied to a "base" input.
          This behaves like Nix's input overrides such as `nixpkgs/<REV>`, where
          `nixpkgs` is registered as an input and `<REV>` is an override used to
          fetch a specific revision of `nixpkgs`.
        '';
        type    = nt.functionTo lib.libfloco.input;
        default = { input, rev ? null, ref ? null }: input;
      };

      getSourcePath = lib.mkOption {
        description = lib.mdDoc ''
          Function which may return the original path of the input outside of
          the nix store (if any).

          This function may return `null` if there is not a non-store path form
          of the input.

          This function largely exists for working with local files/trees.
        '';
        type    = nt.functionTo ( nt.nullOr nt.path );
        default = _: null;
      };

      fetch = lib.mkOption {
        description = lib.mdDoc ''
          Function which fetches an input.

          Returns a pair `{ tree, input }` where `tree` is an attrset with the
          attribute `outPath` ( being a nix store path ), and `input` is the
          locked form of the given `input`.

          Note that the `tree` attrset is not a `lib.libfloco.tree` submodule,
          and may also contain arbitrary attributes.
        '';
        type = nt.functionTo ( nt.submodule {
          options.tree  = lib.mkOption { type = nt.package; };
          options.input = lib.mkOption { type = lib.libfloco.input; };
        } );
      };

    };  # End `inputScheme.option'
  };  # End `inputScheme'`



# ---------------------------------------------------------------------------- #

  input = nt.submodule {
    options = {

      schemeName = lib.mkOption {
        description = lib.mdDoc ''
          Name of the input scheme used to fetch this input.

          This is used when deserializing an input to restore the `functor`
          submodule values.
          If `scheme` is set to `null`, then this attribute must be set.
        '';
        type = nt.nullOr nt.str;
      };

      scheme = lib.mkOption {
        description = lib.mdDoc ''
          The input scheme used to fetch this input.

          The `scheme' attribute may be omitted if the `functor' submodule
          carries all functions required to fetch the input.
          This reduces overhead when the input scheme has finished processing an
          `input` for it to be fetchable.
          If `scheme` is set to `null`, then `schemeName` must be set.
        '';
        type = nt.nullOr lib.libfloco.inputScheme;
      };

      attrs = lib.mkOption {
        description = lib.mdDoc ''
          Attributes which are used to fetch the input.

          These are conventionally arguments passed to the underlying fetcher,
          but may also be used to store other information about the input.
        '';
        type = nt.attrsOf nt.raw;
      };

      parent = lib.mkOption {
        description = lib.mdDoc ''
          For inputs which are fetched from other inputs, this value should be
          an absolute path to the parent input's `tree.outPath` (or equivalent).

          This is used to resolve relative paths in the input.
        '';
        type    = nt.nullOr nt.path;
        default = null;
      };

      functor = lib.mkOption {
        description = lib.mdDoc ''
          Functions which operate on the input to fetch, lock, or otherwise
          manipulate it.

          This generally contains the same functions as the associated
          `inputScheme`, but may be overridden to provide custom behavior.

          This abstraction allows "composed" fetchers to attempt multiple
          `inputSchemes` to find a suitable fetcher for a given input.

          Most of these functions are intended to be called on the parent
          `input` record, but some implementations may accept arbitrary `inputs`
          of the same or compatible `inputScheme`.
          Note that `fromURL` and `fromAttrs` are exceptions to this rule and
          instead act as "constructors" for new inputs of the same scheme.
        '';
        type = nt.submodule {
          options = {

            fromURL = lib.mkOption {
              description = lib.mdDoc ''
                Function that returns a new input of the same `inputScheme`
                from a URL.

                Takes a URL string as an argument.
              '';
              type = nt.functionTo nt.raw;
            };

            fromAttrs = lib.mkOption {
              description = lib.mdDoc ''
                Function that returns a new `input` of the same `inputScheme`
                from an attrset.

                Takes a an attrset as an argument.
              '';
              type = nt.functionTo nt.raw;
            };

            toURL = lib.mkOption {
              description = lib.mdDoc ''
                Function that returns a URL string from an `input`.

                This function may return `null` if there is not a URL form of
                the input.
              '';
              type = nt.functionTo nt.str;
            };

            toAttrs = lib.mkOption {
              description = lib.mdDoc ''
                Function that returns a serializable attrset from an `input`.

                This function may return `null` if there is not a serialized
                form of the input.
              '';
              type = nt.functionTo nt.raw;
            };

            isLocked = lib.mkOption {
              description = lib.mdDoc ''
                Predicate function which returns `true` if the input is locked.

                This means that it is possible to fetch the input in `pure`
                evaluation mode.
              '';
              type    = nt.functionTo nt.bool;
              default = i:
                ( ( i.attrs.narHash or null ) != null ) ||
                ( ( i.attrs.rev or null ) != null );
            };

            isDirect = lib.mkOption {
              description = lib.mdDoc ''
                Predicate function which return `true` if the input is directly
                fetchable without any other inputs or indirection
                through registries.
              '';
              type = nt.functionTo nt.bool;
              default = _: true;
            };

            getType = lib.mkOption {
              description = lib.mdDoc ''
                Function which returns the type of the input.

                This is used to categorize generic inputs which may be
                compatible with multiple `inputSchemes` implementations.
                For example `type = "tarball"` may be used to fetch using
                `fetchTarball`, `fetchzip`, or `fetchTree` schemes.
              '';
              type    = nt.functionTo nt.str;
              default = i: i.scheme.type or i.schemeName;
            };

            getNarHash = lib.mkOption {
              description = lib.mdDoc ''
                Function which returns the NAR hash of the input.
                This may be used to lock the input if it is not already locked.

                This function may return `null` if this information is
                unavailable in the current evaluation mode, or not applicable
                to a given input.

                The default implementation uses `fetch` as a fallback in order
                to reference the `locked` input returned by the fetcher.
              '';
              type    = nt.functionTo ( nt.nullOr lib.libfloco.narHash );
              default = i: let
                n = i.attrs.narHash or null;
              in if n != null then n else
                 ( i.fetch i ).locked.attrs.narHash or null;
            };

            getRev = lib.mkOption {
              description = lib.mdDoc ''
                Function which returns a SHA-1 hex revision hash for the input.
                This may be used to lock the input if it is not already locked.

                This function may return `null` if this information is
                unavailable in the current evaluation mode, or not applicable
                to a given input.

                The default implementation will only check the existing `attrs`
                held by the input - if your input scheme uses `rev` you should
                implement this function explicitly.
              '';
              type    = nt.functionTo ( nt.nullOr lib.libfloco.rev );
              default = i: i.attrs.rev or null;
            };

            getRef = lib.mkOption {
              description = lib.mdDoc ''
                Function which returns a "reference" identifier for the input.
                This is a flexible field whose meaning depends on the input.

                This function may return `null` if this information is
                unavailable in the current evaluation mode, or not applicable
                to a given input.

                The default implementation will only check the existing `attrs`
                held by the input - if your input scheme uses `ref` you should
                implement this function explicitly.
              '';
              type    = nt.functionTo ( nt.nullOr nt.str );
              default = i: i.attrs.ref or null;
            };

            fetch = lib.mkOption {
              description = lib.mdDoc ''
                Function which fetches the input and returns an pair of
                `{ tree, locked }` where `tree.storePath` holds the fetched
                input and `locked` is a locked version of the original input.

                `tree.actualPath` may be used to record the orinal path outside
                of the nix store, if applicable.
              '';
              type = nt.functionTo ( nt.submodule {
                options.tree   = lib.mkOption { type = lib.libfloco.tree; };
                options.locked = lib.mkOption { type = lib.libfloco.input; };
                freeformType   = nt.attrsOf nt.raw;
              } );
              default = input: let
                fetched = input.scheme.fetch input;
              in {
                tree.actualPath = input.scheme.getSourcePath input;
                tree.storePath  = fetched.tree.outPath;
                locked          = fetched.input;
              };
            };

            applyOverrides = lib.mkOption {
              description = lib.mdDoc ''
                Function which applies overrides to the input.

                Overrides are an attrset of `{ input, rev ? null, ref ? null }`
                which may be applied to a "base" input.
                This behaves like Nix's input overrides such as `nixpkgs/<REV>`,
                where `nixpkgs` is registered as an input and `<REV>` is an
                override used to fetch a specific revision of `nixpkgs`.
              '';
              type    = nt.functionTo lib.libfloco.input;
              default = { input, rev ? null, ref ? null }: input;
            };

          };  # End `input.options.functor.type.options'
        };  # End `input.options.functor.type'
      };  # End `input.options.functor'
    };  # End `input.options'
  };  # End `input'


# ---------------------------------------------------------------------------- #

in {

  inherit
    jsonAtom jsonValue

    uri

    version descriptor
    ident key
    ltype
    depAttrs depMetas
    binPairs pjsBin

    relpath storePath

    sha256_hash sha256_sri narHash
    rev short_rev

    tree inputScheme input
  ;

}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
