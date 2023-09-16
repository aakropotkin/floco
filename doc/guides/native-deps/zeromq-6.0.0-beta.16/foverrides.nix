{
  config.floco.packages.zeromq."6.0.0-beta.16".installed = { pkgs, ... }: {

    config.extraBuildInputs = let
    in [
      # Always add this one.
      pkgs.zeromq
    ] ++ ( if ! pkgs.stdenv.hostPlatform.isDarwin then [] else [
      # Only add these for when the host system is `darwin'.
      pkgs.pkg-config
      pkgs.libsodium.dev
    ] );

    # Setting `override' attrs causes them to be set on the underlying
    # derivation, which then get set as environment variables in the
    # sandbox where we run out install.
    # We want to tell `node-gyp' to look for the shared `libzmq', so we'll
    # set the variable we found in their `binding.gyp' file.
    # XXX: You must quote "true" because `binding.gyp' expects a string,
    # and a Nix boolean of `false' gets stringized as the empty string.
    config.override.npm_config_zmq_shared = "true";
    config.override.ARCH                  =
      if pkgs.stdenv.hostPlatform.isx86_64 then "x86_64" else "arm64";
  };

}
