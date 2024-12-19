{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dtc,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "raspberrypi-utils";
  version = "0-unstable-2024-12-18";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "1b9cf7c2224641ff9bb08c9beaa1cdc30aad2a00";
    hash = "sha256-p3Ski8QBWmAhGeB3t/ocjzuLDbkD47JeEVDwD/h59WI=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ dtc ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A collection of scripts and simple applications";
    homepage = "https://github.com/raspberrypi/utils";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };
}
