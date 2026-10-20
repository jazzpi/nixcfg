{
  stdenv,
  lib,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  hidapi,
  tcl,
  jimtcl,
  libjaylink,
  libusb1,
  libgpiod_1,
  libftdi1,
}:
stdenv.mkDerivation {
  pname = "openocd-git";
  # OpenOCD has no releases newer than 0.12.0 (2023), but development has
  # continued upstream (e.g. S32K support). Track a pinned commit until a
  # new release ships.
  version = "0-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "openocd-org";
    repo = "openocd";
    rev = "d2f72d49efed744eaa489ce931393b6e69122e66";
    hash = "sha256-8dVZouBSD1JwtMHWYdKYOOG8rdlUDO7oCd3uCkFkyZA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    tcl
  ];

  buildInputs = [
    libusb1
    hidapi
    jimtcl
    libftdi1
    libjaylink
    libgpiod_1
  ];

  configureFlags = [
    "--disable-werror"
    "--enable-jtag_vpi"
    "--enable-remote-bitbang"
    "--enable-buspirate"
    "--enable-ftdi"
    "--enable-linuxgpiod"
    "--enable-sysfsgpio"
    "--enable-stlink"
    "--enable-cmsis-dap"
    "--enable-cmsis-dap-v2"
    "--enable-jlink"
  ];

  enableParallelBuilding = true;

  passthru.nixUpdateArgs = [
    "--version=branch"
    "--version-regex=(\\d[\\d.]*-unstable-.*)"
  ];

  meta = {
    description = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing (built from git)";
    mainProgram = "openocd";
    homepage = "https://openocd.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
