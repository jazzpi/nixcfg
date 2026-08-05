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
  version = "0.12.0-unstable-2026-07-28";

  src = fetchFromGitHub {
    owner = "openocd-org";
    repo = "openocd";
    rev = "da3920b0a52dc2d394afb222c688dac7e57acc1b";
    hash = "sha256-osZAASRIUDMbDhbH6lIuyx5KtKP7MYaj+WlD6EWpIEo=";
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

  meta = {
    description = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing (built from git)";
    mainProgram = "openocd";
    homepage = "https://openocd.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
