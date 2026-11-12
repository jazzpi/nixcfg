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
  version = "1.1.7";

  src = fetchurl {
    url = "https://github.com/magicbug/OscarWatch-Tracker/releases/download/v${version}/OscarWatch-${version}-linux-x64.tar.gz";
    sha256 = "sha256-Ewf3334hbVZoR7eEt3Kg5KXVXkMeueyepRIFAVEVuGo=";
  };

  # The release tarball doesn't include the icon
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/magicbug/OscarWatch-Tracker/v${version}/OscarWatch/icons/OscarWatch-Icon.png";
    sha256 = "sha256-nYFu3y2+R4tbb8r6VqXO2xz2/3eNbufpDQJh1Z2jz/w=";
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
  ]
  ++ runtimeLibs;

  dontBuild = true;
  dontStrip = true; # GNU strip seems to corrupt .NET PE files

  autoPatchelfIgnoreMissingDeps = [
    "liblttng-ust.so.0" # .NET tracing provider, not needed at runtime
    "libjack.so.0" # starts without. I don't know if recording works without it.
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
    cp $icon $out/share/icons/hicolor/128x128/apps/oscarwatch.png

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

  passthru.nixUpdateArgs = [ ];

  meta = with lib; {
    description = "Amateur satellite tracking application";
    homepage = "https://github.com/magicbug/OscarWatch-Tracker";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "oscarwatch";
  };
}
