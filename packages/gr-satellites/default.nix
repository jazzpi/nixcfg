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
stdenv.mkDerivation {
  pname = "gr-satellites";
  version = "5.8.0";
  src = fetchurl {
    url = "https://github.com/daniestevez/gr-satellites/archive/refs/tags/v5.8.0.tar.gz";
    sha256 = "d6ab0ed48599a290f4d2911816f30de99f91ccf8b2218938538a19b83b98b354";
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
      --prefix PYTHONPATH : "$out/lib/python${python3.pythonVersion}/site-packages" \
      --prefix PYTHONPATH : "${gnuradio}/lib/python${python3.pythonVersion}/site-packages" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
  '';
}
