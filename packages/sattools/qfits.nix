{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qfits";
  version = "5.2.0";

  src = fetchurl {
    url = "https://ftp.eso.org/pub/qfits/qfits-${finalAttrs.version}.tar.gz";
    hash = "sha256-CRCB1+q+ALZa9q6lps0cPqaxgbq6UndRs5bYkQDrYas=";
  };

  postPatch = ''
    substituteInPlace src/xmemory.c \
      --replace-fail 'open(fname, O_RDWR | O_CREAT)' 'open(fname, O_RDWR | O_CREAT, 0644)'
  '';

  hardeningDisable = [ "format" ];

  # The configure script silently gives up if its probe program fails to
  # compile, and that program is K&R C.
  env.NIX_CFLAGS_COMPILE = "-std=gnu89 -fPIC";

  meta = {
    description = "Stand-alone C library for FITS file handling";
    homepage = "https://www.eso.org/sci/software/eclipse/qfits/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
