{
  autoPatchelfHook,
  boost,
  cmake,
  fetchurl,
  gmp,
  gnuradio,
  makeWrapper,
  patchelf,
  pkg-config,
  spdlog,
  stdenv,
  volk,
  ...
}:
let
  python3 = gnuradio.python;
  python3Packages = python3.pkgs;
  pythonEnv = python3.withPackages (
    ps: with ps; [
      numpy
      construct
      requests
      websocket-client
      pyzmq
      pyyaml
      soapysdr-with-plugins
    ]
  );

  runtimeLibs = [
    gnuradio
    spdlog
    boost
    volk
    gmp
    python3Packages.pybind11
    pythonEnv
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gr-satellites";
  version = "5.9.0";
  src = fetchurl {
    url = "https://github.com/daniestevez/gr-satellites/archive/refs/tags/v${finalAttrs.version}.tar.gz";
    sha256 = "sha256-yaM+hVmZGKfhOtzQY2p3pYBUSIaJWiXrMDsVYJp3pBY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    patchelf
    cmake
    makeWrapper
    pkg-config
  ];
  buildInputs = runtimeLibs;

  postFixup = ''
    wrapProgram "$out/bin/gr_satellites" \
      --prefix PYTHONPATH : "$out/${python3.sitePackages}" \
      --prefix PYTHONPATH : "${gnuradio}/${python3.sitePackages}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
  '';

  passthru = {
    inherit pythonEnv python3;
    nixUpdateArgs = [ ];
  };
})
