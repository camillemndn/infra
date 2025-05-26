{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  autoconf,
  automake,
  pkg-config,
  makeWrapper,
  vips,
  chromium,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "phantomas";
  version = "2.17.0";

  src = fetchFromGitHub {
    owner = "macbre";
    repo = "phantomas";
    rev = "v${version}";
    hash = "sha256-TBDtO7dRB9kCq358GZvMofGFr7VG+azP+wL7D0yEmGc=";
  };

  npmDepsHash = "sha256-SwkgufiykpQ5wkALpqkzPfkbNO3pGtT6vl109BgJTpo=";

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    makeWrapper
    vips
  ];

  PUPPETEER_SKIP_DOWNLOAD = true;
  dontNpmBuild = true;

  postInstall = ''
    wrapProgram $out/bin/phantomas \
      --set PUPPETEER_EXECUTABLE_PATH ${lib.getExe chromium}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Headless Chromium-based web performance metrics collector and monitoring tool";
    homepage = "https://github.com/macbre/phantomas";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "phantomas";
    platforms = lib.platforms.all;
  };
}
