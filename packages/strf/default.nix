{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  fftwFloat,
  sox,
}:
stdenv.mkDerivation rec {
  pname = "strf-rffft";
  version = "0-unstable-2026-03-06";

  src = fetchFromGitHub {
    owner = "cbassa";
    repo = "strf";
    rev = "92d24252ca37bb7cbe941b714525f28b59d0463c";
    hash = "sha256-URznu1cpaSpuTQjOlkWvJVJ4sYxeIpBSEC3njaWsuWY=";
  };

  nativeBuildInputs = [ gnumake ];

  buildInputs = [
    fftwFloat
    sox
  ];

  buildPhase = ''
    runHook preBuild
    make -f Makefile.linux rffft CFLAGS="-O3 -Wno-format-overflow"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 rffft $out/bin/rffft
    runHook postInstall
  '';

  meta = with lib; {
    description = "FFT RF observations tool from the Space Traffic and RF (STRF) toolkit";
    homepage = "https://github.com/cbassa/strf";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "rffft";
  };
}
