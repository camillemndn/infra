{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dtc,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "raspberrypi-utils";
  version = "0-unstable-2026-10-14";
  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "7d644432cdb26073411b71021aab9f926f99c563";
    hash = "sha256-Wm+eTa9NdfZLeg6jv4u7HACh9/rAxE1yxXWvqkUi+gg=";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    dtc
    ncurses
  ];
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
