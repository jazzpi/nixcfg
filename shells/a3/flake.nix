{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        fhs = pkgs.buildFHSEnv {
          name = "a3-shell";
          targetPkgs =
            pkgs: with pkgs; [
              brotli.lib
              cups.lib
              libGL
              expat
              krb5.lib
              xorg.libICE
              xorg.libSM
              xorg.libX11
              xorg.libxcb
              xorg.xcbutilwm
              xorg.xcbutilimage
              xorg.xcbutilcursor
              xorg.xcbutilkeysyms
              xorg.xcbutilrenderutil
              libxkbcommon
              wayland
              zlib
            ];
        };
      in
      {
        devShells.default = fhs.env;
      }
    );
}
