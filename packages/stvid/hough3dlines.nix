{
  lib,
  stdenv,
  fetchFromGitLab,
  eigen,
}:
stdenv.mkDerivation {
  pname = "hough3dlines";
  version = "0-unstable-2019-07-28";

  src = fetchFromGitLab {
    owner = "pierros";
    repo = "hough3d-code";
    rev = "6e9c46413c8ac59d4a48ed108709719fb844927c";
    hash = "sha256-6gh7F645WIVtE8Y4ihv7ZuLxGlY8KS1k31xVkqLsBfg=";
  };

  buildInputs = [ eigen ];

  # The Makefile hardcodes LIBEIGEN=/usr/include/eigen3; point it at the Nix eigen.
  makeFlags = [ "LIBEIGEN=${eigen}/include/eigen3" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 hough3dlines $out/bin/hough3dlines
    runHook postInstall
  '';

  meta = with lib; {
    description = "Iterative Hough transform for line detection in 3D point clouds (used by stvid)";
    homepage = "https://gitlab.com/pierros/hough3d-code";
    license = licenses.bsd2;
    platforms = platforms.unix;
    mainProgram = "hough3dlines";
  };
}
