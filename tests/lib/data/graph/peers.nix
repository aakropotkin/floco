let

  defProj = n: attrs: {
    ident        = if builtins.isString n then n else "proj" + ( toString n );
    version      = "4.2.0";
    ltype        = "dir";
    depInfo      = {};
    peerInfo     = {};
    deserialized = true;
  } // attrs;

in {
  config.floco.pdefs = {

    "proj0"."4.2.0" = defProj 0 {
      depInfo.proj1 = {
        pin     = "4.2.0";
        runtime = true;
      };
      depInfo.proj2 = {
        pin     = "4.2.0";
        runtime = false;
      };
      # Marked `optional', but because this is a non-optional `peer' of
      # a non-optional transitive dependency, the resulting `treeInfo' must
      # NOT mark it as optional.
      depInfo.proj5 = {
        pin      = "4.2.0";
        optional = true;
      };
    };

    "proj1"."4.2.0" = defProj 1 {
      # A dev dep which should not appear in our final `treeInfo'.
      depInfo.proj3 = {
        pin = "4.2.0";
        dev     = true;
        runtime = false;
      };
      # A runtime dep, this should appear in our tree because it is a
      # "transitive"/indirect dependency on `proj0'.
      depInfo.proj4 = {
        pin     = "4.2.0";
        runtime = true;
      };
      # A peer dependency which is satisfied by the declared dep in `proj0'.
      # See note above about how `optional' is being tested here.
      # Because we have marked this as a non-optional peer, it must not be
      # optional in the resulting tree regardless of how `proj0' has marked it.
      peerInfo.proj5 = {
        descriptor = "^4.2.0";
        optional   = false;
      };
    };

    "proj2"."4.2.0" = defProj 2 {
      # An optional transitive dep from the perspective of `proj0'.
      depInfo.proj6 = {
        pin = "4.2.0";
        runtime  = true;
        optional = true;
      };
    };

    # Leaves
    "proj3"."4.2.0" = defProj 3 {};
    "proj4"."4.2.0" = defProj 4 {};
    "proj5"."4.2.0" = defProj 5 {};
    "proj6"."4.2.0" = defProj 6 {};

  };  # End `floco.pdefs'
}
