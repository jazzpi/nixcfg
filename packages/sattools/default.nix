{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  makeWrapper,
  gfortran,
  libX11,
  libpng,
  libjpeg,
  libexif,
  gsl,
  wcslib,
  coreutils,
  dos2unix,
  gawk,
  gnugrep,
  gnused,
  unzip,
  wget,
}:
let
  pgplot = callPackage ../pgplot { };
  qfits = callPackage ./qfits.nix { };
in
stdenv.mkDerivation {
  pname = "sattools";
  version = "0-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "jazzpi";
    repo = "sattools";
    rev = "e65b652cf21e288dc2a52b63d2d4dc8ecb04ac6c";
    hash = "sha256-zhAPTDI7YDgUF9nwlJwEn/mXLP42gBnPHDTYqhqQlZw=";
  };

  nativeBuildInputs = [
    gfortran
    makeWrapper
  ];

  buildInputs = [
    pgplot
    qfits
    libX11
    libpng
    libjpeg
    libexif
    gsl
    wcslib
  ];

  makeFlags = [ "CFLAGS=-O2 -Wno-unused-result" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin bin/*
    wrapProgram $out/bin/tleupdate \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          dos2unix
          gawk
          gnugrep
          gnused
          unzip
          wget
        ]
      }
    runHook postInstall
  '';

  passthru = {
    inherit pgplot qfits;
    nixUpdateArgs = [ "--version=branch=fix-sprintf" ];
  };

  meta = {
    description = "Collection of tools for photographic and video satellite tracking";
    homepage = "https://github.com/cbassa/sattools";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
