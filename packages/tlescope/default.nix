{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  raylib,
  curl,
  libGL,
  libx11,
}:

stdenv.mkDerivation {
  pname = "tlescope";
  version = "0-unstable-2026-10-31";

  src = fetchFromGitHub {
    owner = "aweeri";
    repo = "TLEscope";
    rev = "826f2a6722836e9d53ba9994230c8f24c3d28db8";
    hash = "sha256-C3rOnniShGFoyu5r3uenc8SxPrUgpBjCrNZHw4D8zGc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    raylib
    curl
    libGL
    libx11
  ];

  # The Makefile links against the vendored raylib archives; point it at
  # the nixpkgs one instead. GIT_VERSION is pinned because there is no .git.
  makeFlags = [
    "bin/TLEscope"
    "LIB_LIN_PATH="
    "GIT_VERSION=vUnknown"
    "CC_LINUX=${stdenv.cc.targetPrefix}cc"
  ];
  # Needs a space, which makeFlags would word-split.
  preBuild = ''
    mkdir -p build bin
    makeFlagsArray+=("LDFLAGS_LIN=-lraylib -lcurl -lGL -lm -lpthread -ldl -lrt -lX11")
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/TLEscope $out/libexec/TLEscope/TLEscope
    cp -r themes $out/libexec/TLEscope/
    install -Dm644 logo.png $out/share/icons/hicolor/512x512/apps/TLEscope.png
    install -Dm644 logo.png $out/libexec/TLEscope/logo.png

    # The app reads themes/, logo.png, settings.json and data.tle from its
    # working directory, and writes data.tle/persistence.bin back there, so
    # run it from a writable per-user dir that links to the immutable assets.
    mkdir -p $out/bin
    cat > $out/bin/TLEscope <<LAUNCHER
    #!${stdenv.shell}
    d="\''${XDG_CONFIG_HOME:-\$HOME/.config}/TLEscope"
    mkdir -p "\$d"
    ln -sfn $out/libexec/TLEscope/themes "\$d/themes"
    ln -sfn $out/libexec/TLEscope/logo.png "\$d/logo.png"
    cd "\$d" && exec $out/libexec/TLEscope/TLEscope "\$@"
    LAUNCHER
    chmod +x $out/bin/TLEscope

    mkdir -p $out/share/applications
    cat > $out/share/applications/TLEscope.desktop <<DESKTOP
    [Desktop Entry]
    Type=Application
    Name=TLEscope
    Exec=TLEscope
    Icon=TLEscope
    Terminal=false
    Categories=Utility;Science;
    DESKTOP

    runHook postInstall
  '';

  passthru.nixUpdateArgs = [
    "--version=branch"
    "--version-regex=(\\d[\\d.]*-unstable-.*)"
  ];

  meta = {
    description = "Satellite tracker and TLE visualiser";
    homepage = "https://github.com/aweeri/TLEscope";
    license = lib.licenses.agpl3Only;
    mainProgram = "TLEscope";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
