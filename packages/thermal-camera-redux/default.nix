{
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  wrapGAppsHook,
  patchelf,
  pkg-config,
  gtk2,
  opencv,
  glibc,
  lib,
}:
let
  opencvWithGtk = opencv.override (_: { enableGtk2 = true; });
  runtimeLibs = [
    opencvWithGtk
    gtk2
  ];
in
stdenv.mkDerivation {
  name = "Thermal-Camera-Redux";

  src = fetchFromGitHub {
    owner = "92es";
    repo = "Thermal-Camera-Redux";
    rev = "f95a696e26367f9ba418b131be559b48f6cb61bc";
    sha256 = "sha256-F09lo/7qi74/jKUP++HJ3ibOn/BOqZB3KhzTJep5ZLI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
    patchelf
    pkg-config
    gtk2
  ];
  buildInputs = runtimeLibs;

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
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/Thermal-Camera-Redux
  '';

  postFixup = ''
    gappsWrapperArgs+=(
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    )
  '';
}
