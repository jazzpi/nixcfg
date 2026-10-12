{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs_22,
  nodejs-slim_22,
  pnpm_10,
  pnpmConfigHook,
  pnpmBuildHook,
}:

let
  pnpm = pnpm_10.override { nodejs-slim = nodejs-slim_22; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-devtools";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "matt1398";
    repo = "claude-devtools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+FqdFMeyZOL9HV5OfNdzSn5QE/d3vveO4QEYfk0WT38=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-KfRVapMs+m3s0fUxPCf+KLK1yN8cu4eKDsNlhqHH5SM=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs_22
    pnpm
    pnpmConfigHook
    pnpmBuildHook
  ];

  # Builds only the HTTP server + web UI, not the Electron app.
  pnpmBuildScript = "standalone:build";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall

    # The bundle leaves the fastify packages external, so it needs a
    # production node_modules next to it. Reinstall from scratch: pruning in
    # place leaves the dev deps in node_modules/.pnpm.
    rm -rf node_modules
    pnpm install --offline --prod --ignore-scripts --frozen-lockfile

    dir=$out/lib/claude-devtools
    mkdir -p $dir/out
    cp -r package.json node_modules dist-standalone $dir/
    cp -r out/renderer $dir/out/

    makeWrapper ${lib.getExe nodejs_22} $out/bin/claude-devtools \
      --add-flags $dir/dist-standalone/index.cjs \
      --set-default NODE_ENV production

    runHook postInstall
  '';

  meta = {
    description = "Web UI for exploring Claude Code session logs";
    homepage = "https://github.com/matt1398/claude-devtools";
    license = lib.licenses.mit;
    mainProgram = "claude-devtools";
    platforms = lib.platforms.linux;
  };
})
