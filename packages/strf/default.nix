{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  gfortran,
  fftwFloat,
  sox,
  libX11,
  libpng,
  gsl,
}:
let
  pgplot = callPackage ../pgplot { };
in
stdenv.mkDerivation {
  pname = "strf";
  version = "0-unstable-2026-03-06";

  src = fetchFromGitHub {
    owner = "cbassa";
    repo = "strf";
    rev = "92d24252ca37bb7cbe941b714525f28b59d0463c";
    hash = "sha256-URznu1cpaSpuTQjOlkWvJVJ4sYxeIpBSEC3njaWsuWY=";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    pgplot
    fftwFloat
    sox
    libX11
    libpng
    gsl
  ];

  makeFlags = [ "CFLAGS=-O3 -Wno-format-overflow" ];

  # tleupdate is left out: sattools ships a more up-to-date copy of it.
  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin rfedit rfplot rffft rfpng rffit rffind rfdop
    runHook postInstall
  '';

  passthru = {
    inherit pgplot;
    nixUpdateArgs = [
      "--version=branch"
      "--version-regex=(\\d[\\d.]*-unstable-.*)"
    ];
  };

  meta = {
    description = "Radio frequency satellite tracking toolkit";
    homepage = "https://github.com/cbassa/strf";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "rfplot";
  };
}
