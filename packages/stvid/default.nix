{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  callPackage,
  makeWrapper,
  python3,
}:
let
  # Native helper binaries stvid shells out to.
  hough3dlines = callPackage ./hough3dlines.nix { };
  satpredict = callPackage ./satpredict.nix { };

  # NOTE: this is the "lightweight" build -- it deliberately omits the optical
  # plate-solving tools (astrometry.net's solve-field and SExtractor), which are
  # not in nixpkgs and are large from-scratch builds. update_tle / acquire and
  # the Hough-based track detection work; astrometric calibration in process.py
  # will fail at runtime until those two binaries are added to PATH.

  pythonEnv = python3.withPackages (
    ps:
    let
      represent = ps.callPackage ./represent.nix { };
      rush = ps.callPackage ./rush.nix { };
      spacetrack = ps.callPackage ./spacetrack.nix { inherit represent rush; };
    in
    [
      ps.astropy
      ps.numpy
      ps.opencv4
      ps.scipy
      ps.matplotlib
      ps.termcolor
      ps.pyyaml
      ps.gpiozero
      ps.readchar
      spacetrack
    ]
  );

  # bin name -> source script
  scripts = {
    stvid-acquire = "acquire.py";
    stvid-process = "process.py";
    stvid-update-tle = "update_tle.py";
    stvid-imgstat = "imgstat.py";
    stvid-keogram = "keogram.py";
  };
in
stdenvNoCC.mkDerivation {
  pname = "stvid";
  version = "0-unstable-2026-06-14";

  src = fetchFromGitHub {
    owner = "cbassa";
    repo = "stvid";
    rev = "6c8676629230b00ac0a65cc89908b888bc35e18c";
    hash = "sha256-XfdPlAyfMRJCDkViuZm6SmLkDAQ+89A9/URS2BMV4j4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/stvid
    cp -r . $out/share/stvid

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (bin: script: ''
        makeWrapper ${pythonEnv}/bin/python3 $out/bin/${bin} \
          --add-flags $out/share/stvid/${script} \
          --prefix PATH : ${lib.makeBinPath [ hough3dlines satpredict ]} \
          --set ST_DATADIR $out/share/stvid
      '') scripts
    )}

    runHook postInstall
  '';

  passthru = { inherit hough3dlines satpredict pythonEnv; };

  meta = with lib; {
    description = "Satellite tracking with video cameras (lightweight Nix build, no plate-solving)";
    longDescription = ''
      stvid detects, measures and identifies satellites in video/CMOS observations.
      Exposed commands: stvid-acquire, stvid-process, stvid-update-tle,
      stvid-imgstat, stvid-keogram. This build bundles the hough3dlines and
      satpredict helpers but not astrometry.net/SExtractor.
    '';
    homepage = "https://github.com/cbassa/stvid";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "stvid-process";
  };
}
