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
}:

buildNpmPackage rec {
  pname = "phantomas";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "macbre";
    repo = "phantomas";
    rev = "v${version}";
    hash = "sha256-TsJqZ5ElQCeYy4lhF8Ouhaf4tLhTjQc7RBsj5Sdq+ic=";
  };

  npmDepsHash = "sha256-UNw1w5u/8kYpzvL4QpEn8xJeVHVevvxQ/fd8+Qxw/Ts=";

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

  meta = with lib; {
    description = "Headless Chromium-based web performance metrics collector and monitoring tool";
    homepage = "https://github.com/macbre/phantomas";
    license = licenses.bsd2;
    maintainers = with maintainers; [ camillemndn ];
    mainProgram = "phantomas";
    platforms = platforms.all;
  };
}
