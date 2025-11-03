# Adapted from https://wiki.nixos.org/wiki/Rust#Installation_via_rustup
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          strictDeps = true;
          nativeBuildInputs = [
            rustup
            rustPlatform.bindgenHook
            pkg-config
            flip-link
            probe-rs
          ];
          buildInputs = [
            # Libraries here
            openssl
          ];
          RUSTC_VERSION = "stable";
          shellHook = ''
            export PATH="''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-${stdenv.hostPlatform.rust.rustcTarget}/bin:''${CARGO_HOME:-~/.cargo}/bin:$PATH"
          '';
        };
      }
    );
}
