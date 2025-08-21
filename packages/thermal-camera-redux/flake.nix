{
  description = "Yamcs Studio";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        opencvWithGtk = pkgs.opencv.override (old: {
          enableGtk2 = true;
        });
        runtimeLibs = with pkgs; [
          # xorg.libX11
          # xorg.libXext
          # xorg.libXrender
          # xorg.libXtst
          # xorg.libXi
          # alsa-lib
          # gtk3
          # atk
          # at-spi2-atk
          # cairo
          # glib
          opencvWithGtk
          gtk2
        ];
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "Thermal-Camera-Redux";

          src = pkgs.fetchFromGitHub {
            owner = "92es";
            repo = "Thermal-Camera-Redux";
            rev = "f95a696e26367f9ba418b131be559b48f6cb61bc";
            sha256 = "sha256-F09lo/7qi74/jKUP++HJ3ibOn/BOqZB3KhzTJep5ZLI=";
          };

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            wrapGAppsHook
            patchelf
            pkg-config
            gtk2
          ];
          buildInputs = runtimeLibs;
          # autoPatchelfIgnoreMissingDeps = [ "libc.so.8" ];

          unpackPhase = ''
            ls
          '';

          buildPhase = ''
            cp -r $src/src .
            cd src
            chmod +w . build_redux
            ls -lh
            sed -i '1a set -x' build_redux
            bash build_redux
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp redux $out/bin/Thermal-Camera-Redux
            patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/Thermal-Camera-Redux
            # cat > $out/bin/yamcs-studio <<EOF
            # #!/bin/sh
            # export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (runtimeLibs)}:\$LD_LIBRARY_PATH"
            # export SWT_GTK3=1
            # cd "$out/opt/yamcs"
            # exec "./Yamcs Studio" -nosplash "\$@"
            # EOF
            # chmod +x $out/bin/yamcs-studio
          '';

          postFixup = ''
            gappsWrapperArgs+=(
              --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
            )
          '';
        };
      }
    );
}
