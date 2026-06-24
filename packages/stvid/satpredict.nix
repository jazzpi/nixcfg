{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "satpredict";
  version = "0-unstable-2022-12-27";

  src = fetchFromGitHub {
    owner = "cbassa";
    repo = "satpredict";
    rev = "00c4e6ee60bc8918aad3f659e3c8067a77e761ae";
    hash = "sha256-BnHhLb3ptG4vKZTzhrksfgFsere4oJfmKlVukijCXtg=";
  };

  # Pure C, links only libm; the default target builds the `satpredict` binary.
  installPhase = ''
    runHook preInstall
    install -Dm755 satpredict $out/bin/satpredict
    runHook postInstall
  '';

  meta = with lib; {
    description = "Predict satellite positions from TLEs (used by stvid)";
    homepage = "https://github.com/cbassa/satpredict";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "satpredict";
  };
}
