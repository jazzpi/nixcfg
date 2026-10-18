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
  version = "0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "ppapadeas";
    repo = "sattools";
    rev = "c57fc1b956f2f0ccfbf1f55890b4e821894acda6";
    fetchSubmodules = true;
    hash = "sha256-n1ClLgxxnf967Klb0ST1LgRoAKbhk79FazZC76EqR2c=";
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
    nixUpdateArgs = [ "--version=branch=shared-sgp4" ];
  };

  meta = {
    description = "Collection of tools for photographic and video satellite tracking";
    homepage = "https://github.com/cbassa/sattools";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
