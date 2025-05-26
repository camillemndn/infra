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
  version = "0-unstable-2025-05-22";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "657359cd6d6d8ebc6ba431750dc3c2c1d91fd707";
    hash = "sha256-D+KKexWKAmLmBjPZ4qTz7BLjB83T3Mr+rHIqNX7c6Pg=";
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
