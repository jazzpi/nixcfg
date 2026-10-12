{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glibc,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  alsa-lib,
  fontconfig,
  freetype,
  makeDesktopItem,
  copyDesktopItems,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "astroimagej";
  version = "6.0.11.00";

  src = fetchurl {
    url = "https://github.com/AstroImageJ/astroimagej/releases/download/${finalAttrs.version}/AstroImageJ-${finalAttrs.version}-linux-x64.tgz";
    sha256 = "sha256-bWQg6sOjo/n5NCjWpECoG16CYnrmtH3Qyu4J8QSYe24=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    glibc
    libx11
    libxext
    libxi
    libxrender
    libxtst
    alsa-lib
    fontconfig
    freetype
  ];

  dontBuild = true;

  unpackPhase = ''
    tar -xzf $src --strip-components=1
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/astroimagej
    cp -r . $out/opt/astroimagej

    # Force libfontmanager to hard-link fontconfig so it doesn't fail on dlopen
    patchelf --add-needed libfontconfig.so \
      $out/opt/astroimagej/lib/runtime/lib/libfontmanager.so

    install -Dm644 $out/opt/astroimagej/lib/AstroImageJ.png \
      $out/share/icons/hicolor/512x512/apps/astroimagej.png

    makeWrapper $out/opt/astroimagej/bin/AstroImageJ $out/bin/astroimagej \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ fontconfig freetype ]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "astroimagej";
      desktopName = "AstroImageJ";
      comment = "Astronomical image analysis tool based on ImageJ";
      exec = "astroimagej %f";
      icon = "astroimagej";
      categories = [ "Science" "Education" ];
      mimeTypes = [ "image/fits" ];
    })
  ];

  passthru.nixUpdateArgs = [ ];

  meta = {
    description = "Astronomical image analysis tool based on ImageJ";
    homepage = "https://www.astro.louisville.edu/software/astroimagej/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "astroimagej";
  };
})
