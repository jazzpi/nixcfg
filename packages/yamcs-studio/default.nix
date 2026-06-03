{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook,
  patchelf,
  glibc,
  xorg,
  alsa-lib,
  gtk3,
  atk,
  at-spi2-atk,
  cairo,
  glib,
  lib,
}:
let
  runtimeLibs = [
    glibc
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    alsa-lib
    gtk3
    atk
    at-spi2-atk
    cairo
    glib
  ];
in
stdenv.mkDerivation {
  name = "yamcs-studio";

  src = fetchurl {
    url = "https://github.com/yamcs/yamcs-studio/releases/download/v1.7.9/yamcs-studio-1.7.9-linux.gtk.x86_64.tar.gz";
    sha256 = "25856c82bd7e3b79edd8acc8eac7c1d51a805165eb3ca5209da4371bd49bca1e";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
    patchelf
    glibc
  ];
  buildInputs = runtimeLibs;
  autoPatchelfIgnoreMissingDeps = [ "libc.so.8" ];

  unpackPhase = ''
    mkdir yamcs
    tar -xzf $src -C yamcs --strip-components=1
    cd yamcs
  '';

  installPhase = ''
    mkdir -p $out/opt/yamcs
    cp -r . $out/opt/yamcs
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 "$out/opt/yamcs/Yamcs Studio"
    mkdir -p $out/bin
    cat > $out/bin/yamcs-studio <<EOF
    #!/bin/sh
    export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeLibs}:\$LD_LIBRARY_PATH"
    export SWT_GTK3=1
    cd "$out/opt/yamcs"
    exec "./Yamcs Studio" -nosplash "\$@"
    EOF
    chmod +x $out/bin/yamcs-studio
  '';

  postFixup = ''
    gappsWrapperArgs+=(
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    )
  '';
}
