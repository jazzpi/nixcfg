{
  lib,
  stdenv,
  fetchurl,
  gfortran,
  libX11,
  libpng,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pgplot";
  version = "5.2.2";

  src = fetchurl {
    urls = [
      "https://deb.debian.org/debian/pool/non-free/p/pgplot5/pgplot5_${finalAttrs.version}.orig.tar.gz"
      "ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot${lib.versions.majorMinor finalAttrs.version}.tar.gz"
    ];
    hash = "sha256-pXmf9xmlENhNJt9K50Ca5h/mZHfj8eiCBCKppHJ6W+Q=";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    libX11
    libpng
    zlib
  ];

  # Uncommented entries of drivers.list are compiled in.
  drivers = [
    "NUDRIV"
    "GIDRIV"
    "PNDRIV"
    "PPDRIV"
    "PSDRIV"
    "XWDRIV"
  ];

  # makemake only understands its own conf files, so write one for gfortran.
  # The old C needs pre-C99 semantics (implicit int, K&R prototypes), and
  # -ffixed-line-length-none lets the store path fit into grgfil.f.
  nixConf = ''
    XINCL=""
    MOTIF_INCL=""
    ATHENA_INCL=""
    TK_INCL=""
    RV_INCL=""
    FCOMPL="gfortran"
    FFLAGC="-u -fPIC -O2 -ffixed-line-length-none -fallow-argument-mismatch -std=legacy"
    FFLAGD="-fno-backslash"
    CCOMPL="cc"
    CFLAGC="-fPIC -DPG_PPU -O2 -std=gnu89 -fpermissive -w"
    CFLAGD="-O2"
    PGBIND_FLAGS="bsd"
    LIBS="-lX11"
    MOTIF_LIBS=""
    ATHENA_LIBS=""
    TK_LIBS=""
    RANLIB="ranlib"
    SHARED_LIB="libpgplot.so"
    SHARED_LD="gfortran -shared -o $SHARED_LIB"
    SHARED_LIB_LIBS="-lX11 -lpng -lz"
    MCOMPL=""
    MFLAGC=""
    SYSDIR="$SYSDIR"
  '';
  passAsFile = [ "nixConf" ];

  postPatch = ''
    for drv in $drivers; do
      sed -i -E "s/^! ($drv )/  \1/" drivers.list
    done

    # The makefile wants vendored png/zlib headers in the build dir.
    sed -i '/^pndriv.o : .\/png.h/d' makemake
    # libpng >= 1.5 made png_struct opaque.
    substituteInPlace drivers/pndriv.c \
      --replace-fail 'png_ptr->jmpbuf' 'png_jmpbuf(png_ptr)'

    substituteInPlace src/grgfil.f \
      --replace-fail "DEFDIR='/usr/local/pgplot/'" "DEFDIR='$out/lib/pgplot/'"
    substituteInPlace drivers/xwdriv.c \
      --replace-fail \
        '(exe=find_exe(getenv("PATH"), PGXWIN_SERVER))==NULL) {' \
        '(exe=find_exe(getenv("PATH"), PGXWIN_SERVER))==NULL &&
       (exe=find_exe("'"$out"'/lib/pgplot", PGXWIN_SERVER))==NULL) {'

    cp $nixConfPath sys_linux/nix_gcc.conf
  '';

  configurePhase = ''
    runHook preConfigure
    mkdir build
    cd build
    cp ../drivers.list .
    ../makemake .. linux nix_gcc
    runHook postConfigure
  '';

  buildFlags = [
    "lib"
    "grfont.dat"
    "pgxwin_server"
    "cpg"
  ];

  # Building in parallel races on the shared ar archives.
  enableParallelBuilding = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/lib libpgplot.a libpgplot.so libcpgplot.a
    install -Dm644 -t $out/include cpgplot.h
    install -Dm644 -t $out/lib/pgplot grfont.dat rgb.txt
    install -Dm755 -t $out/lib/pgplot pgxwin_server
    runHook postInstall
  '';

  meta = {
    description = "Device-independent graphics package for making scientific graphs";
    homepage = "https://sites.astro.caltech.edu/~tjp/pgplot/";
    # Free for non-commercial use; redistribution of modified versions is not
    # permitted.
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
})
