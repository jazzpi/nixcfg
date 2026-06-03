{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  openssl,
  zlib,
  alsa-lib,
  libx11,
  libxi,
  libxcursor,
  libxrender,
  libxrandr,
  libxext,
  libice,
  libsm,
  libxkbcommon,
  freetype,
  fontconfig,
  libGL,
  icu,
}:
let
  runtimeLibs = [
    openssl
    libx11
    libxi
    libxcursor
    libxrender
    libxrandr
    libxext
    libice
    libsm
    libxkbcommon
    freetype
    fontconfig
    libGL
    icu
  ];
in
stdenv.mkDerivation rec {
  pname = "oscarwatch";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/magicbug/OscarWatch-Tracker/releases/download/v${version}/OscarWatch-${version}-linux-x64.tar.gz";
    sha256 = "35fc06db3e56934d1ab9811ec9f8198d19e128b48f4d3a7277965c26c41d68db";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    alsa-lib
  ] ++ runtimeLibs;

  dontBuild = true;
  dontStrip = true; # GNU strip corrupts .NET PE files (mangles composite R2R machine type 0xfd1d)

  autoPatchelfIgnoreMissingDeps = [
    "liblttng-ust.so.0" # .NET tracing provider, not needed at runtime
    "libjack.so.0" # optional JACK audio backend in portaudio; ALSA is used instead
  ];

  unpackPhase = ''
    mkdir source
    tar -xzf $src -C source
  '';

  sourceRoot = "source";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/oscarwatch
    cp -r . $out/lib/oscarwatch/

    mkdir -p $out/bin
    makeWrapper $out/lib/oscarwatch/OscarWatch $out/bin/oscarwatch \
      --prefix LD_LIBRARY_PATH : "$out/lib/oscarwatch" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp help/oscarwatch-icon.png $out/share/icons/hicolor/128x128/apps/oscarwatch.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "oscarwatch";
      desktopName = "OscarWatch Tracker";
      comment = "Amateur satellite tracking application";
      exec = "oscarwatch";
      icon = "oscarwatch";
      categories = [
        "HamRadio"
        "Science"
      ];
    })
  ];

  meta = with lib; {
    description = "Amateur satellite tracking application";
    homepage = "https://github.com/magicbug/OscarWatch-Tracker";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "oscarwatch";
  };
}
